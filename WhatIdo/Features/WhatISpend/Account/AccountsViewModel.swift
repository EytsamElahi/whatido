//
//  AccountsViewModel.swift
//  WhatIdo
//

import Foundation
import SwiftUI

enum AccountTab: String, CaseIterable {
  case accounts = "Accounts"
  case income   = "Income"
  case sources  = "Sources"
}

@MainActor
class AccountsViewModel: ObservableObject {
  // MARK: - Published Properties
  @Published var accounts: [AccountDto] = []
  @Published var incomeSources: [IncomeSourceDto] = []
  @Published var incomeTransactions: [IncomeTransactionDto] = []
  @Published var isLoading = false
  @Published var errorMessage: String? = nil
  @Published var showAddSheet: Bool = false
  @Published var showAdjustSheet: Bool = false
  @Published var showAddIncomeSheet: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var selectedAccount: AccountDto?
  @Published var selectedIncomeSource: IncomeSourceDto?
  @Published var listRefreshID = UUID()
  @Published var selectedTab: AccountTab = .accounts
  @Published var totalAssets: Double = 0
  @Published var totalLiabilities: Double = 0
  @Published var netWorth: Double = 0

  private let overlayManager = OverlayManager.shared
  private let service: AccountServiceProtocol

  // MARK: - Init
  init(service: AccountServiceProtocol) {
    self.service = service
  }

  // MARK: - Net Worth

  private func calculateNetWorth() {
    totalAssets = accounts
      .filter { !$0.type.isLiability }
      .reduce(0) { $0 + $1.currentBalance }
    totalLiabilities = accounts
      .filter { $0.type.isLiability }
      .reduce(0) { $0 + $1.currentBalance }
    netWorth = totalAssets - totalLiabilities
  }

  // MARK: - Fetch Data

  func fetchData() {
    Task { [weak self] in
      guard let self = self else { return }
      overlayManager.showLoader()
      defer { overlayManager.hideLoader() }
      async let accountsResult = service.getAllAccounts()
      async let sourcesResult = service.getAllIncomeSources()

      let (accRes, srcRes) = await (accountsResult, sourcesResult)

      switch srcRes {
      case .data(let data): self.incomeSources = data
      default: break
      }
      switch accRes {
      case .data(let data):
        let mapped = mapSourceToAccount(accounts: data, sources: incomeSources)
        self.accounts = mapped
        self.calculateNetWorth()
        self.takeMonthlySnapshotIfNeeded()
      case .error(let err): self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  func fetchIncomeTransactions() {
    Task { [weak self] in
      guard let self = self else { return }
      let result = await service.getIncomeTransactions()
      if case .data(let txs) = result {
        let accountLookup = accounts.reduce(into: [String: String]()) { dict, acc in
          dict[acc.id] = acc.name
        }
        self.incomeTransactions = txs
          .map { $0.convertToDto(accountName: accountLookup[$0.accountId] ?? "") }
          .sorted { $0.receivedAt > $1.receivedAt }
      }
    }
  }

  // MARK: - Income Transactions

  func addIncomeTransaction(
    accountId: String,
    sourceId: String,
    sourceName: String,
    amount: Double,
    currency: String,
    note: String?,
    receivedAt: Date
  ) {
    Task { [weak self] in
      guard let self = self else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let tx = IncomeTransaction(
        accountId: accountId,
        sourceId: sourceId,
        sourceName: sourceName,
        amount: amount,
        currency: currency,
        note: note,
        receivedAt: receivedAt
      )
      tx.id = UUID().uuidString
      let accountName = accounts.first(where: { $0.id == accountId })?.name ?? ""
      let result = await service.addIncomeTransaction(tx)
      switch result {
      case .data(let saved):
        self.incomeTransactions.insert(saved.convertToDto(accountName: accountName), at: 0)
        self.showAddIncomeSheet = false
        self.overlayManager.showToast(message: "Income recorded", style: .success)
        await self.refreshAccount(id: accountId)
      case .error(let err):
        self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  // MARK: - Transfers

  func addTransfer(
    fromAccountId: String,
    toAccountId: String,
    amount: Double,
    fee: Double?,
    currency: String,
    note: String?
  ) {
    Task { [weak self] in
      guard let self = self else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let fromName = accounts.first(where: { $0.id == fromAccountId })?.name ?? ""
      let toName   = accounts.first(where: { $0.id == toAccountId })?.name ?? ""
      let transfer = AccountTransfer(
        fromAccountId: fromAccountId,
        fromAccountName: fromName,
        toAccountId: toAccountId,
        toAccountName: toName,
        amount: amount,
        fee: fee,
        currency: currency,
        note: note
      )
      transfer.id = UUID().uuidString
      let result = await service.addTransfer(transfer)
      switch result {
      case .success:
        self.showTransferSheet = false
        self.overlayManager.showToast(message: "Transfer complete", style: .success)
        self.fetchData()
      case .error(let err):
        self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  // MARK: - Net Worth Snapshot

  func takeMonthlySnapshotIfNeeded() {
    Task { [weak self] in
      guard let self = self else { return }
      let calendar = Calendar.current
      let now = Date()
      let currentMonthKey = "\(calendar.component(.year, from: now))-\(calendar.component(.month, from: now))"
      guard AppData.lastSnapshotMonth != currentMonthKey else { return }
      let breakdown = accounts.map { acc in
        AccountBalanceSnapshot(
          accountId: acc.id,
          accountName: acc.name,
          balance: acc.currentBalance,
          currency: acc.currency,
          type: acc.type
        )
      }
      let snapshot = NetWorthSnapshot(
        totalAssets: self.totalAssets,
        totalLiabilities: self.totalLiabilities,
        accountBreakdown: breakdown
      )
      snapshot.id = UUID().uuidString
      let result = await service.saveNetWorthSnapshot(snapshot)
      if case .success = result {
        AppData.lastSnapshotMonth = currentMonthKey
      }
    }
  }

  // MARK: - Adjust Balance

  func adjustAccountBalance(to newBalance: Double) {
    guard let account = selectedAccount else { return }
    self.isLoading = true
    Task { [weak self] in
      guard let self = self else { return }
      defer { self.isLoading = false }
      let updatedAccount = Account(
        name: account.name,
        type: account.type,
        openingBalance: account.openingBalance,
        cachedBalance: newBalance,
        currency: account.currency,
        sourceId: account.sourceId,
        isArchived: account.isArchived,
        created: account.createdAt
      )
      updatedAccount.id = account.id
      let result = await service.editAccount(updatedAccount)
      switch result {
      case .success:
        if let index = self.accounts.firstIndex(where: { $0.id == account.id }) {
          self.accounts[index] = updatedAccount.convertToDto()
          self.calculateNetWorth()
        }
        self.overlayManager.showToast(message: "Balance adjusted!", style: .success)
        self.showAdjustSheet = false
      case .error(let err):
        self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  // MARK: - Helpers

  func openSheet(tab: AccountTab) {
    switch tab {
    case .accounts:
      selectedAccount = nil
      showAddSheet = true
    case .income:
      showAddIncomeSheet = true
    case .sources:
      selectedIncomeSource = nil
      showAddSheet = true
    }
  }

  private func refreshAccount(id: String) async {
    let result = await service.recomputeAndSyncBalance(accountId: id)
    if case .data(let newBalance) = result,
       let index = accounts.firstIndex(where: { $0.id == id }) {
      let old = accounts[index]
      accounts[index] = AccountDto(
        id: old.id, name: old.name, type: old.type,
        openingBalance: old.openingBalance, currentBalance: newBalance,
        currency: old.currency, sourceId: old.sourceId,
        isArchived: old.isArchived, createdAt: old.createdAt, isDefault: old.isDefault
      )
      calculateNetWorth()
    }
  }

  private func mapSourceToAccount(accounts: [AccountDto], sources: [IncomeSourceDto]) -> [AccountDto] {
    let sourceLookup = sources.reduce(into: [String: IncomeSourceDto]()) { dict, source in
      dict[source.id] = source
    }
    let updated = accounts.map { account -> AccountDto in
      var newAccount = account
      if let matched = sourceLookup[newAccount.sourceId ?? ""] {
        newAccount.sourceName = matched.name
      }
      return newAccount
    }
    return updated.filter { !$0.isArchived }
  }
}

// MARK: - Account Operations
extension AccountsViewModel {

  func createAccount(name: String, type: AccountType, balance: Double, sourceId: String?) {
    Task { [weak self] in
      guard let self = self else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let accountId = UUID().uuidString
      guard let currency = AppData.prefCurrency else { return }
      let newAccount = Account(
        name: name,
        type: type,
        openingBalance: balance,
        currency: currency.code,
        sourceId: sourceId
      )
      newAccount.id = accountId
      let result = await service.addAccount(newAccount)
      switch result {
      case .data(let dto):
        self.accounts.append(dto)
        self.calculateNetWorth()
        self.overlayManager.showToast(message: "Account created successfully", style: .success)
        self.showAddSheet = false
      case .error(let err):
        self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  func updateAccount(name: String, type: AccountType, sourceId: String?) {
    Task { [weak self] in
      guard let self = self,
            let currency = AppData.prefCurrency,
            let account = selectedAccount else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let updatedAccount = Account(
        name: name,
        type: type,
        openingBalance: account.openingBalance,
        cachedBalance: account.currentBalance,
        currency: currency.code,
        sourceId: sourceId,
        isArchived: account.isArchived,
        created: account.createdAt
      )
      updatedAccount.id = account.id
      let result = await service.editAccount(updatedAccount)
      if case .error(let string) = result {
        self.overlayManager.showToast(message: string, style: .error)
        return
      }
      self.overlayManager.showToast(message: "Account updated successfully", style: .success)
      if let index = accounts.firstIndex(where: { $0.id == account.id }) {
        self.accounts[index] = updatedAccount.convertToDto()
        self.showAddSheet = false
        self.calculateNetWorth()
      }
    }
  }

  func deleteAccount(_ id: String) {
    overlayManager.showPopup(
      title: "Delete Account?",
      message: "This account will be hidden from your list. Your past transactions will remain in your history to keep your reports accurate.",
      style: .warning,
      primaryAction: PopupAction(title: "Delete", role: .destructive) {
        self.performDeleteAccount(id)
      },
      secondaryAction: PopupAction(title: "Cancel", role: .cancel) {}
    )
  }

  func editAccount(_ account: AccountDto) {
    selectedAccount = nil
    selectedAccount = account
    showAddSheet = true
  }

  func markAsDefault(account: AccountDto) {
    Task { [weak self] in
      guard let self = self else { return }
      self.overlayManager.showLoader()
      let result = await service.updateDefaultAccount(selectedId: account.id, allActiveAccounts: self.accounts)
      await MainActor.run {
        self.overlayManager.hideLoader()
        switch result {
        case .success:
          self.accounts = self.accounts.map { acc in
            AccountDto(
              id: acc.id, name: acc.name, type: acc.type,
              openingBalance: acc.openingBalance, currentBalance: acc.currentBalance,
              currency: acc.currency, sourceId: acc.sourceId,
              isArchived: acc.isArchived, createdAt: acc.createdAt,
              isDefault: (acc.id == account.id)
            )
          }
          self.overlayManager.showToast(message: "Default account updated", style: .success)
        case .error(let err):
          self.overlayManager.showToast(message: err, style: .error)
        default: break
        }
      }
    }
  }

  private func performDeleteAccount(_ id: String) {
    Task { [weak self] in
      guard let self = self else { return }
      let result = await service.deleteAccount(id)
      if case .error(let string) = result {
        self.overlayManager.showToast(message: string, style: .error)
        return
      }
      self.accounts.removeAll(where: { $0.id == id })
      self.calculateNetWorth()
      self.overlayManager.showToast(message: "Account deleted successfully", style: .success)
    }
  }
}

// MARK: - Income Source Operations
extension AccountsViewModel {

  func createSource(name: String) {
    Task { [weak self] in
      guard let self = self else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let newSource = IncomeSource(name: name)
      newSource.id = UUID().uuidString
      let result = await service.addIncomeSource(newSource)
      switch result {
      case .data(let dto):
        self.incomeSources.append(dto)
        self.overlayManager.showToast(message: "Source created successfully", style: .success)
        self.showAddSheet = false
      case .error(let err):
        self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  func updateSource(name: String) {
    Task { [weak self] in
      guard let self = self else { return }
      guard let source = selectedIncomeSource else { return }
      self.isLoading = true
      defer { self.isLoading = false }
      let newSource = IncomeSource(name: name, created: source.createdAt)
      newSource.id = source.id
      let result = await service.addIncomeSource(newSource)
      if case .error(let string) = result {
        self.overlayManager.showToast(message: string, style: .error)
        return
      }
      self.overlayManager.showToast(message: "Source updated successfully", style: .success)
      if let index = incomeSources.firstIndex(where: { $0.id == source.id }) {
        self.incomeSources[index] = newSource.convertToDto()
        self.showAddSheet = false
      }
    }
  }

  func deleteIncomeSource(_ index: Int) {
    overlayManager.showPopup(
      title: "Delete Source?",
      message: "Are you sure you want to delete this source? This action cannot be undone.",
      style: .warning,
      primaryAction: PopupAction(title: "Delete", role: .destructive) {
        self.performDeleteIncomeSource(at: index)
      },
      secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
        self.listRefreshID = UUID()
      }
    )
  }

  func editSource(_ source: IncomeSourceDto) {
    selectedIncomeSource = nil
    selectedIncomeSource = source
    showAddSheet = true
  }

  private func performDeleteIncomeSource(at index: Int) {
    let id = incomeSources[index].id
    Task { [weak self] in
      guard let self = self else { return }
      let result = await service.deleteIncomeSource(id)
      if case .error(let string) = result {
        self.overlayManager.showToast(message: string, style: .error)
        return
      }
      self.incomeSources.remove(at: index)
      self.overlayManager.showToast(message: "Source deleted successfully", style: .success)
    }
  }
}
