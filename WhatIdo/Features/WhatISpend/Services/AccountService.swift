//
//  AccountService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import Foundation

protocol AccountServiceProtocol {
    func getAllAccounts() async -> AppResult<[AccountDto]>
    func addAccount(_ account: Account) async -> AppResult<AccountDto>
    func getAllIncomeSources() async -> AppResult<[IncomeSourceDto]>
    func addIncomeSource(_ source: IncomeSource) async -> AppResult<IncomeSourceDto>
    func deleteAccount(_ id: String) async -> AppResult<Void>
    func deleteIncomeSource(_ id: String) async -> AppResult<Void>
    func editAccount(_ account: Account) async -> AppResult<Void>
    func editIncomeSource(_ source: IncomeSource) async -> AppResult<Void>
    func updateDefaultAccount(selectedId: String, allActiveAccounts: [AccountDto]) async -> AppResult<Void>
}

final class AccountService: FirebaseService, AccountServiceProtocol {
    
    // 1. Fetch Accounts
    func getAllAccounts() async -> AppResult<[AccountDto]> {
        do {
            let data: [Account] = try await request(orderBy: "created", endpoint: FirestoreEndpoints.getAllAccounts)
            let dtos = data.map { $0.convertToDto() }
            return .data(dtos)
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    // 2. Add Account
    func addAccount(_ account: Account) async -> AppResult<AccountDto> {
        do {
            let savedAccount = try await post(data: account, endpoint: FirestoreEndpoints.createAccount(id: account.id))
            return .data(savedAccount.convertToDto())
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    // 3. Fetch Income Sources
    func getAllIncomeSources() async -> AppResult<[IncomeSourceDto]> {
        do {
            let data: [IncomeSource] = try await request(orderBy: "created", endpoint: FirestoreEndpoints.getAllIncomeSources)
            let dtos = data.map { $0.convertToDto() }
            return .data(dtos)
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    // 4. Add Income Source
    func addIncomeSource(_ source: IncomeSource) async -> AppResult<IncomeSourceDto> {
        do {
            let savedSource = try await post(data: source, endpoint: FirestoreEndpoints.createIncomeSource(id: source.id))
            return .data(savedSource.convertToDto())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func deleteAccount(_ id: String) async -> AppResult<Void> {
        let endPoint = FirestoreEndpoints.createAccount(id: id)
        do {
            try await updateCollectionProperties(FirestoreQueryParam(key: "isArchived", value: true), endpoint: endPoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func deleteIncomeSource(_ id: String) async -> AppResult<Void> {
        let endpoint = FirestoreEndpoints.createIncomeSource(id: id)
        do {
            try await delete(endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func editAccount(_ account: Account) async -> AppResult<Void> {
        do {
            let _ = try await update(data: account, endpoint: FirestoreEndpoints.createAccount(id: account.id))
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func editIncomeSource(_ source: IncomeSource) async -> AppResult<Void> {
        do {
            let _ = try await update(data: source, endpoint: FirestoreEndpoints.createIncomeSource(id: source.id))
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func updateDefaultAccount(selectedId: String, allActiveAccounts: [AccountDto]) async -> AppResult<Void> {
        do {
            var instructions: [(endpoint: FirestoreEndpoint, params: [FirestoreQueryParam])] = []
            for acc in allActiveAccounts {
                let endpoint = FirestoreEndpoints.createAccount(id: acc.id)
                let isDefault = (acc.id == selectedId)

                instructions.append((
                    endpoint: endpoint,
                    params: [FirestoreQueryParam(key: "isDefault", value: isDefault)]
                ))
            }
            try await performBatchUpdate(instructions: instructions)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

}
