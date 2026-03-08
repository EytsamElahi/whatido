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

  // MARK: - Long-lived Services (lazy init)
  private lazy var spendingsService: SpendingsServiceProtocol = SpendingsService()
  private lazy var projectsService: ProjectsServiceProtocol = ProjectsService()
  private lazy var budgetsService: BudgetsServiceProtocol = BudgetsService()
  private lazy var authService: AuthServiceProtocol = FirebaseAuthService()
  private lazy var accountService: AccountServiceProtocol = AccountService()
  private lazy var goalsService: GoalsServiceProtocol = GoalsService()
  private lazy var userRepo: UserRepositoryType = UserRepository()

  // THE EVENT BUS (Signal)
  let eventBus = PassthroughSubject<AppGlobalEvent, Never>()

  init() {
    // Services are now initialized lazily
  }

  // MARK: - ViewModel Factories

  // 1. Dashboard (Main Screen)
  @MainActor
  func makeDashboardViewModel() -> SpendingsViewModel {
    return SpendingsViewModel(
      spendingService: spendingsService,
      budgetService: budgetsService,
      accountService: accountService,
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
  func makeTransactionFormViewModel(spendingToEdit: SpendingDto? = nil, selectedProject: ProjectDto? = nil) -> AddSpendingViewModel {
    return AddSpendingViewModel(
      service: spendingsService,
      spendingToEdit: spendingToEdit,
      selectedProject: selectedProject,
      eventBus: eventBus
    )
  }

  // 4. Budget Settings
  @MainActor
  func makeBudgetViewModel(budgetToEdit: Budget? = nil) -> BudgetViewModel {
    return BudgetViewModel(service: budgetsService, budgetToEdit: budgetToEdit)
  }

  @MainActor
  func makeAnalyticsViewModel() -> AnalyticsViewModel {
    return AnalyticsViewModel(service: spendingsService)
  }

  @MainActor
  func makeGoalsViewModel() -> GoalsViewModel {
    return GoalsViewModel(goalsService: goalsService)
  }

  @MainActor
  func makeLoginViewModel() -> AuthenticationViewModel {
    return AuthenticationViewModel(authService: authService)
  }

  @MainActor
  func makeAccountsViewModel() -> AccountsViewModel {
    return AccountsViewModel(service: accountService)
  }

  @MainActor
  func makeSettingsViewModel() -> SettingsViewModel {
    return SettingsViewModel(authService: authService, userRepo: userRepo)
  }

  @MainActor
  func makeCurrencySettingsViewModel() -> CurrencySettingsViewModel {
    return CurrencySettingsViewModel(
      userRepo: userRepo,
      eventBus: eventBus
    )
  }
}
