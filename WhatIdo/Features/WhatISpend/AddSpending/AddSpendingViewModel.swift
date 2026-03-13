//
//  TransactionFormViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

@MainActor
class AddSpendingViewModel: ObservableObject {
  private let service: SpendingsServiceProtocol
  private let projectService: ProjectsServiceProtocol
  private let accountService: AccountServiceProtocol

  // MARK: - Form Fields
  @Published var spendingItemTf: String = ""
  @Published var amountTf: Double = 0
  @Published var dateTf: String = ""
  @Published var selectedTypeName: String = "" {
    didSet {
      selectedType = spendingTypes.first(where: {$0.name == selectedTypeName})
    }
  }
  @Published var currentMonthInDateFormat: Date? = Date().getFirstDateOfMonth()
  // Dropdown Data
  @Published var spendingTypes: [SpendingType] = []
  @Published var selectedType: SpendingType?
  @Published var accounts: [AccountDto] = []
  @Published var selectedAccountName: String = "" {
    didSet {
      selectedAccount = accounts.first(where: {$0.name == selectedAccountName})
    }
  }
  @Published var selectedAccount: AccountDto?

  // Linked Project
  @Published var selectedProject: ProjectDto?
  @Published var projects: [ProjectDto]?

  // State
  @Published var isDataUploading: Bool = false
  @Published var showErrorAlert: Bool = false
  @Published var dismissSheet: Bool = false

  var spending: SpendingDto?
  // Edit Mode Helper
  var spendingIdToEdit: String?
  private var created: Date?
  private let overlayManager = OverlayManager.shared
  private let eventBus: PassthroughSubject<AppGlobalEvent, Never>
  private var spendingToEdit: SpendingDto?
  private let analytics = AnalyticsManager.shared

  // Task management for proper cancellation
  private var savingTask: Task<Void, Never>?
  private var projectsTask: Task<Void, Never>?

  init(service: SpendingsServiceProtocol = SpendingsService(), projectSerivce: ProjectsServiceProtocol = ProjectsService(), accountService: AccountServiceProtocol = AccountService(), spendingToEdit: SpendingDto? = nil, selectedProject: ProjectDto? = nil, eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
    self.service = service
    self.projectService = projectSerivce
    self.accountService = accountService
    self.eventBus = eventBus
    self.selectedProject = selectedProject
    self.loadSpendingTypes()
    self.getProjects()
    self.fetchAccounts()

    if let spending = spendingToEdit {
      self.spendingToEdit = spending
      self.spendingIdToEdit = spending.id
      self.spendingItemTf = spending.name
      self.amountTf = spending.amount
      self.dateTf = spending.date.toDateReturnString() // Helper method
      self.selectedTypeName = spending.type
      self.created = spending.created
    }
  }

  deinit {
    savingTask?.cancel()
    projectsTask?.cancel()
  }

  private func loadSpendingTypes() {
    let types: [SpendingType] = Helper.load("spending_types.json")
    self.spendingTypes = sortByUsage(types)
  }

  private func sortByUsage(_ types: [SpendingType]) -> [SpendingType] {
    // Priority order: Most commonly used categories first
    let priorityOrder = [
      "Dining Out", "Groceries", "Fuel", "Public Transit / Taxi",
      "Utility Bills", "Subscriptions", "Movies & Outings", "Rent",
      "Pharmacy / Meds", "Clothing & Tailor", "Salon & Grooming"
    ]
    return types.sorted { first, second in
      let firstIndex = priorityOrder.firstIndex(of: first.name ?? "") ?? Int.max
      let secondIndex = priorityOrder.firstIndex(of: second.name ?? "") ?? Int.max
      return firstIndex < secondIndex
    }
  }

  // MARK: - Save Action
  func saveSpending() {
    guard validateForm() else {
      showErrorAlert = true
      return
    }
    let date = dateTf.toTimeStamp(format: "MM/dd/yyyy") ?? Date()
    let accountTypeInfo: DAccountType
    if let account = selectedAccount {
      accountTypeInfo = DAccountType(name: account.name, accountId: account.id, isLiability: account.type.isLiability)
    } else {
      accountTypeInfo = DAccountType(name: "Unlinked", accountId: nil)
    }

    // Use category name if description is empty
    let name = spendingItemTf.isEmpty ? (selectedType?.name ?? "") : spendingItemTf

    // Create Object
    let spending = Spending(
      name: name,
      amount: amountTf,
      date: date,
      spendingType: selectedType,
      created: created ?? Date(),
      projectType: ProjectInfo(id: selectedProject?.id, name: selectedProject?.name, icon: selectedProject?.icon),
      accountType: accountTypeInfo,
      currencyCode: CurrencyManager.shared.currencyCode
    )
    savingTask = Task { [weak self] in
      guard let self else { return }
      self.isDataUploading = true
      defer {
        self.isDataUploading = false
      }
      if let id = spendingIdToEdit, let oldSpending = spendingToEdit {
        spending.id = id
        let apiResult = await service.editSpending(oldSpending: oldSpending, newSpending: spending, spendingId: id)
        if case .error(let error) = apiResult {
          self.overlayManager.showToast(message: error, style: .error)
          return
        }
        self.analytics.logExpenseEdited()
        self.overlayManager.showToast(message: PopupMessages.dataUpdatedMessage("Spending"), style: .success)
        eventBus.send(.reloadDashboard)
        self.spending = spending.convertToDto()
      } else {
        let apiResult = await service.addSpending(spending)
        switch apiResult {
        case .data(let newSpending):
          self.spending = newSpending
          self.analytics.logExpenseAdded(
            category: selectedType?.name ?? "Unknown",
            amount: amountTf
          )
          eventBus.send(.reloadDashboard)
          self.overlayManager.showToast(message: PopupMessages.dataAddedMessage("Spending"), style: .success)
        case .error(let error):
          self.overlayManager.showToast(message: error, style: .error)
          return
        default:
          break
        }
      }
      self.dismissSheet = true
    }
  }

  private func fetchAccounts() {
    Task { [weak self] in
      guard let self = self else { return }
      let result = await accountService.getAllAccounts()
      switch result {
      case .data(let data):
        self.accounts = data.filter {!$0.isArchived}
        if let account = accounts.first(where: {$0.isDefault == true}) {
          self.selectedAccount = account
          self.selectedAccountName = account.name
        }
      case .error(let err): self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

  private func validateForm() -> Bool {
    // Description is optional for quick add
    return amountTf > 0.0 && selectedType != nil
  }

  private func getProjects() {
    projectsTask = Task { [weak self] in
      guard let self else { return }
      let result = await projectService.getProjects()
      if case .data(let data) = result {
        self.projects = data
      }
    }
  }
}
