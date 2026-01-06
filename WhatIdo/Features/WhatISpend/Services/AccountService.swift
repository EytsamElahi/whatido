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
}
