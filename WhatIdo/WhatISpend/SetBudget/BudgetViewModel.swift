//
//  BudgetViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI

@MainActor
class BudgetViewModel: ObservableObject {
    private let service: BudgetsServiceProtocol
    
    @Published var budgetAmount: Double?
    @Published var monthlyBudget: Budget?
    @Published var isUploading: Bool = false
    @Published var budgetUpdated: Bool = false

    private var currentMonth: String = Date().getMonthName()
    private var currentMonthInDateFormat: Date? = Date().getFirstDateOfMonth()

    init(service: BudgetsServiceProtocol = BudgetsService(), budgetToEdit: Budget?) {
        self.service = service
        self.monthlyBudget = budgetToEdit
    }
    
    func setBudget() {
        guard let amount = budgetAmount else { return }
        isUploading = true
        let budget = Budget(month: self.currentMonth, year: self.currentMonthInDateFormat?.components.year ?? 0, budgetAmount: amount)
        Task {
            let result = await service.addMonthlyBudget(budget)
            if case .data(let newBudget) = result {
                self.monthlyBudget = newBudget
                self.budgetAmount = newBudget.budgetAmount
            }
            isUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.budgetUpdated = true
            }
        }
    }
    
    func deleteBudget() {
        guard let id = monthlyBudget?.id else { return }
        isUploading = true
        Task {
            _ = await service.deleteMonthlyBudget(id)
            self.budgetAmount = nil
            self.monthlyBudget = nil
            isUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.budgetUpdated = true
            }
        }
    }

    func setOrUpdateBudget() {
        if monthlyBudget ==  nil {
            setBudget()
        } else {
            updateBudgetAmount()
        }
    }

    private func updateBudgetAmount() {
        guard let amount = budgetAmount else { return }
        guard let cBudget = monthlyBudget else {return}
        self.isUploading = true
        cBudget.budgetAmount = amount
        Task {@MainActor in
            let result = await service.editMonthlyBudget(cBudget, id: cBudget.id)
            if case(.success) = result {
                self.budgetAmount = cBudget.budgetAmount
            } else {
                debugPrint("Error in fetching budget")
            }
            self.isUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.budgetUpdated = true
            }
        }
    }
}
