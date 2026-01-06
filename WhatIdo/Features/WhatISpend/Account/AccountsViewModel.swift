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
    
    // 4. Add Account
    func createAccount(name: String, type: AccountType, balance: Double, sourceId: String) {
        // Convert Color to Hex
       // let hex = color.toHex() ?? "#FFFFFF"
        Task { [weak self] in
            guard let self = self else {return}
            self.isLoading = true
            defer {
                self.isLoading = false
            }
            let accountId = UUID().uuidString
            guard let currency = AppData.prefCurrency else {return}
            let newAccount = Account(name: name, type: type, balance: balance, currency: currency.code, sourceId: sourceId)
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
}
