//
//  AppDependencyContainer.swift
//  WhatIdo
//
//  Created by eytsam elahi on 19/12/2025.
//

import Foundation
import Combine

// AppEvents.swift
enum AppGlobalEvent {
    case reloadDashboard              // Simple reload
    case projectDeleted(id: String)   // Data ke sath event
    case budgetUpdated(newAmount: Double)
    case userLoggedOut
}

class AppDependencyContainer {

    // MARK: - Long-lived Services (Singletons)
    // Yeh puri app mein sirf ek baar banengi
    private let spendingsService: SpendingsServiceProtocol
    private let projectsService: ProjectsServiceProtocol
    private let budgetsService: BudgetsServiceProtocol
    // 🔥 THE EVENT BUS (Signal)
    let eventBus = PassthroughSubject<AppGlobalEvent, Never>()

    init() {
        // Initialize Core Services
        self.spendingsService = SpendingsService()
        self.projectsService = ProjectsService()
        self.budgetsService = BudgetsService()
    }

    // MARK: - ViewModel Factories

    // 1. Dashboard (Main Screen)
    @MainActor
    func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(
            spendingService: spendingsService,
            budgetService: budgetsService,
            eventBus: eventBus
        )
    }

    // 2. Projects Listing & Management
    @MainActor
    func makeProjectsViewModel() -> ProjectsViewModel {
        return ProjectsViewModel(
            projectService: projectsService,
            spendingService: spendingsService,
            eventBus: eventBus
        )
    }

    // 3. Add/Edit Transaction Form
    // Note: Isay hum optional 'spending' pass karte hain (Edit case ke liye)
    @MainActor
    func makeTransactionFormViewModel(spendingToEdit: SpendingDto? = nil) -> AddSpendingViewModel {
        return AddSpendingViewModel(
            service: spendingsService,
            spendingToEdit: spendingToEdit
        )
    }

    // 4. Budget Settings
    @MainActor
    func makeBudgetViewModel(budgetToEdit: Budget? = nil) -> BudgetViewModel {
        return BudgetViewModel(service: budgetsService, budgetToEdit: budgetToEdit)
    }
}
