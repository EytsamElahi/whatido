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
    private let overlayManager = OverlayManager.shared

    init(service: BudgetsServiceProtocol = BudgetsService(), budgetToEdit: Budget?) {
        self.service = service
        self.monthlyBudget = budgetToEdit
    }
    
    func setBudget() {
        guard let amount = budgetAmount else { return }
        isUploading = true
        let budget = Budget(
            month: self.currentMonth,
            year: self.currentMonthInDateFormat?.components.year ?? 0,
            budgetAmount: amount
        )

        Task { [weak self] in
            guard let self = self else { return }
            defer {
                self.isUploading = false
            }
            let result = await service.addMonthlyBudget(budget)
            switch result {
            case .data(let newBudget):
                self.monthlyBudget = newBudget
                self.budgetAmount = newBudget.budgetAmount
                self.overlayManager.showToast(message: PopupMessages.dataAddedMessage("Budget"), style: .success)
                self.budgetUpdated = true
            case .error(let errorMessage):
                self.overlayManager.showToast(message: errorMessage, style: .error)
            default:
                debugPrint("")
            }
        }
    }
    
    func deleteBudget() {
        guard let id = monthlyBudget?.id else { return }
        isUploading = true

        Task { [weak self] in
            guard let self = self else { return }
            defer {
                self.isUploading = false
            }
            let result = await service.deleteMonthlyBudget(id)
            switch result {
            case .success, .data:
                self.budgetAmount = nil
                self.monthlyBudget = nil

                self.overlayManager.showToast(message: "Budget deleted successfully", style: .success)
                self.budgetUpdated = true

            case .error(let errorMessage):
                self.overlayManager.showToast(message: errorMessage, style: .error)
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
        guard var cBudget = monthlyBudget else { return }

        self.isUploading = true
        cBudget.budgetAmount = amount

        Task { [weak self] in
            guard let self = self else { return }
            defer {
                self.isUploading = false
            }
            let result = await service.editMonthlyBudget(cBudget, id: cBudget.id)
            switch result {
            case .success, .data:
                self.budgetAmount = cBudget.budgetAmount
                self.monthlyBudget = cBudget
                self.overlayManager.showToast(message: PopupMessages.dataUpdatedMessage("Budget"), style: .success)
                self.budgetUpdated = true

            case .error(let errorMsg):
                self.overlayManager.showToast(message: errorMsg, style: .error)
            }
        }
    }
}
