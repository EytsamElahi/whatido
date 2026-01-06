//
//  AccountsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import Foundation
import SwiftUI

@MainActor
class AccountsViewModel: ObservableObject {
    // 1. Published Properties (UI State)
    @Published var accounts: [AccountDto] = []
    @Published var incomeSources: [IncomeSourceDto] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showAddSheet: Bool = false
    @Published var selectedAccount: AccountDto?
    @Published var selectedIncomeSource: IncomeSourceDto?
    @Published var listRefreshID = UUID()
    private let overlayManager = OverlayManager.shared

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.currentBalance }
    }
    
    private let service: AccountServiceProtocol
    
    // Dependency Injection
    init(service: AccountServiceProtocol) {
        self.service = service
    }
    
    // 3. Fetch Data
    func fetchData() {
        Task { [weak self] in
            guard let self = self else {return}
            overlayManager.showLoader()
            defer {
                overlayManager.hideLoader()
            }
            async let accountsResult = service.getAllAccounts()
            async let sourcesResult = service.getAllIncomeSources()

            let (accRes, srcRes) = await (accountsResult, sourcesResult)

            switch srcRes {
            case .data(let data): self.incomeSources = data
            default: break // Silent fail for sources optional
            }
            switch accRes {
            case .data(let data):
                let accounts = mapSourceToAccount(accounts: data, sources: incomeSources)
                self.accounts = accounts
            case .error(let err): self.overlayManager.showToast(message: err, style: .error)
            default: break
            }
        }
    }

    // 5. Add Source
    func createSource(name: String) {
        Task { [weak self] in
            guard let self = self else {return}
            self.isLoading = true
            defer {
                self.isLoading = false
            }
            let newSource = IncomeSource(name: name)
            let sourceId = UUID().uuidString
            newSource.id = sourceId
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
            guard let self = self else {return}
            guard let source = selectedIncomeSource else {return}
            self.isLoading = true
            defer {
                self.isLoading = false
            }
            let newSource = IncomeSource(name: name, created: source.createdAt)
            newSource.id = source.id
            let result = await service.addIncomeSource(newSource)
            if case .error(let string) = result {
                self.overlayManager.showToast(message: string, style: .error)
                return
            }
            self.overlayManager.showToast(message: "Source updated successfully", style: .success)
            if let index = incomeSources.firstIndex(where: {$0.id == source.id}) {
                self.incomeSources[index] = newSource.convertToDto()
                self.showAddSheet = false
            }
        }

    }

    private func mapSourceToAccount(accounts: [AccountDto], sources: [IncomeSourceDto]) -> [AccountDto]{
        let accountLookup = sources.reduce(into: [String: IncomeSourceDto]()) { dict, account in
                dict[account.id] = account
            }
            let updatedAccounts = accounts.map { account -> AccountDto in
                var newAccount = account
                if let matchedAccount = accountLookup[newAccount.sourceId] {
                    newAccount.sourceName = matchedAccount.name
                }
                return newAccount
            }
            return updatedAccounts
    }

    func deleteAccount(_ id: String) {
        overlayManager.showPopup(
                title: "Delete Account?",
                message: "Are you sure you want to delete this account? This action cannot be undone.",
                style: .warning,
                primaryAction: PopupAction(title: "Delete", role: .destructive) {
                    self.performDeleteAccount(id)
                },
                secondaryAction: PopupAction(title: "Cancel", role: .cancel) {}
            )
    }

}

// MARK: - Functions related to Accounts
extension AccountsViewModel {

    func createAccount(name: String, type: AccountType, balance: Double, sourceId: String) {
        Task { [weak self] in
            guard let self = self else {return}
            self.isLoading = true
            defer {
                self.isLoading = false
            }
            let accountId = UUID().uuidString
            guard let currency = AppData.prefCurrency else {return}
            let newAccount = Account(name: name, type: type, balance: balance, currency: currency.code, sourceId: sourceId, created: selectedAccount?.createdAt)
            newAccount.id = accountId

            let result = await service.addAccount(newAccount)
            switch result {
            case .data(let dto):
                self.accounts.append(dto)
                self.overlayManager.showToast(message: "Account created successfully", style: .success)
                self.showAddSheet = false
            case .error(let err):
                self.overlayManager.showToast(message: err, style: .error)
            default: break
            }
        }
    }
    func updateAccount(name: String, type: AccountType, balance: Double, sourceId: String) {
        Task { [weak self] in
            guard let self = self else {return}
            guard let currency = AppData.prefCurrency else {return}
            guard let account = selectedAccount else {return}
            self.isLoading = true
            defer {
                self.isLoading = false
            }
            let newAccount = Account(name: name, type: type, balance: balance, currency: currency.code, sourceId: sourceId, created: account.createdAt)
            newAccount.id = account.id
            let result = await service.editAccount(newAccount)
            if case .error(let string) = result {
                self.overlayManager.showToast(message: string, style: .error)
                return
            }
            self.overlayManager.showToast(message: "Account updated successfully", style: .success)
            if let index = accounts.firstIndex(where: {$0.id == account.id}) {
                self.accounts[index] = newAccount.convertToDto()
                self.showAddSheet = false
            }
        }

    }
    private func performDeleteAccount(_ id: String) {
        Task {[weak self] in
            guard let self = self else {return}
            let result = await service.deleteAccount(id)
            if case .error(let string) = result {
                self.overlayManager.showToast(message: string, style: .error)
                return
            }
            self.accounts.removeAll(where: {$0.id == id})
            self.overlayManager.showToast(message: "Account deleted successfully", style: .success)
        }
    }

    func editAccount(_ account: AccountDto) {
        selectedAccount = nil
        selectedAccount = account
        showAddSheet = true
    }
}

// MARK: - Functions related to Income Source
extension AccountsViewModel {
    func deleteIncomeSource(_ index: Int) {
        overlayManager.showPopup(
                title: "Delete Account?",
                message: "Are you sure you want to delete this account? This action cannot be undone.",
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
        Task {[weak self] in
            guard let self = self else {return}
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
