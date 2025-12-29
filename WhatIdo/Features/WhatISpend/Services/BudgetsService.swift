//
//  BudgetsService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import Foundation

protocol BudgetsServiceProtocol {
    func getMonthlyBudget(id: String) async -> AppResult<Budget>
    func addMonthlyBudget(_ budget: Budget) async -> AppResult<Budget>
    func deleteMonthlyBudget(_ id: String) async -> AppResult<Void>
    func editMonthlyBudget(_ budget: Budget, id: String) async -> AppResult<Budget>
}

final class BudgetsService: FirebaseService, BudgetsServiceProtocol {
    
    func getMonthlyBudget(id: String) async -> AppResult<Budget> {
        do {
            let budget: Budget = try await request(endpoint: FirestoreEndpoints.getBudget(id: id))
            return .data(budget)
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func addMonthlyBudget(_ budget: Budget) async -> AppResult<Budget> {
        do {
            let savedBudget = try await post(data: budget, endpoint: FirestoreEndpoints.addBudget(year: budget.year, month: budget.month))
            return .data(savedBudget)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func deleteMonthlyBudget(_ id: String) async -> AppResult<Void> {
        do {
            let endpoint = FirestoreEndpoints.deleteBudget(id: id)
            try await delete(endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    func editMonthlyBudget(_ budget: Budget, id: String) async -> AppResult<Budget> {
        do {
            let endpoint = FirestoreEndpoints.editBudget(id: id)
            try await update(data: budget, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
