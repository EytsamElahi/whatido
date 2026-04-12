//
//  DashboardViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

@MainActor
class SpendingsViewModel: ObservableObject {
  // Services
  private let spendingService: SpendingsServiceProtocol
  private let budgetService: BudgetsServiceProtocol
  let accountService: AccountServiceProtocol

  // MARK: - Data
  @Published var currentMonthSpendings: [SpendingDto]?
  @Published var totalSpending: Int = 0
  @Published var monthlyBudget: Budget?
  @Published var accounts: [AccountDto] = []

  // Date Management
  @Published var currentMonth: String = Date().getMonthName()
  @Published var currentMonthDate: Date? = Date().getFirstDateOfMonth()

  // Sorting
  @Published var selectedSortType: MenuItem = MenuItem(id: 0, name: "Date")
  private(set) var spendingSortTypes: [MenuItem] = [MenuItem(id: 0, name: "Date"), MenuItem(id: 1, name: "Amount")]

  // Navigation/Sheet States (Booleans only)
  @Published var showAddSheet: Bool = false
  @Published var showBudgetSheet: Bool = false
  @Published var showProjectsSheet: Bool = false
  @Published var showFilterSheet: Bool = false
  @Published var showSearchBar: Bool = false

  // Delete Spending
  @Published var showDeleteConfirmationAlert: Bool = false
  var spendingToDelete: SpendingDto?
  var spendingToDeleteIndex: Int?

  // MARK: - Search / Filter / Sort
  @Published var searchText: String = ""
  @Published var filters: SpendingFilters = SpendingFilters()
  @Published var sortOption: SpendingSortOption = .default

  // Loading State
  @Published var isDataLoading: Bool = false

  private let overlayManager = OverlayManager.shared

  // Edit State
  var spendingToEdit: SpendingDto?
  private var cancellables = Set<AnyCancellable>()

  // Computed for budget progress
  var convertedBudgetAmount: Double {
    guard let budget = monthlyBudget else { return 0 }
    let budgetCurrency = budget.currencyCode ?? "USD"
    let homeCurrency = CurrencyManager.shared.activeCurrency?.code ?? "USD"

    if budgetCurrency == homeCurrency {
      return budget.budgetAmount
    }

    let rateToUSD = CurrencyConfig.rates[budgetCurrency] ?? 1.0
    let budgetInUSD = budget.budgetAmount / rateToUSD
    let homeRate = CurrencyConfig.rates[homeCurrency] ?? 1.0

    return (budgetInUSD * homeRate).rounded()
  }

  var hasForeignBudget: Bool {
    guard let budget = monthlyBudget else { return false }
    return (budget.currencyCode ?? "USD") != CurrencyManager.shared.activeCurrency?.code ?? "USD"
  }

  init(spendingService: SpendingsServiceProtocol,
       budgetService: BudgetsServiceProtocol,
       accountService: AccountServiceProtocol,
       eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
    self.spendingService = spendingService
    self.budgetService = budgetService
    self.accountService = accountService
    // LISTENER (SUBSCRIBER)
    eventBus
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.fetchDashboardData()
      }
      .store(in: &cancellables)
    fetchAccounts()
  }

  // MARK: - Fetch Logic
  func fetchDashboardData() {
    isDataLoading = true
    Task {
      // 1. Fetch Spendings
      let spendingResult = await spendingService.getSpendingsOfMonth(currentMonthDate ?? Date())
      if case .data(let spendings) = spendingResult {
        self.currentMonthSpendings = spendings.filter {!$0.isArchived}
        self.calculateTotal()
      }
      if case .error(let string) = spendingResult {
        self.overlayManager.showToast(message: string, style: .error)
      }
      withAnimation(.easeOut(duration: 0.4)) {
        self.isDataLoading = false
      }

      // 2. Fetch Budget
      let budgetId = "\(AppData.user?.id ?? "")_\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
      let budgetResult = await budgetService.getMonthlyBudget(id: budgetId)
      if case .data(let budget) = budgetResult {
        self.monthlyBudget = budget
      }
    }
  }

  func deleteSpending() {
    guard let index = spendingToDeleteIndex else { return }
    guard let spendings = currentMonthSpendings else { return }
    let spending = spendings[index]

    Task {
      let result = await spendingService.deleteSpending(spending)
      if case .success = result {
        self.overlayManager.showToast(message: "Spending deleted successfully", style: .success)
      }
      if case(.error(let string)) = result {
        self.overlayManager.showToast(message: string, style: .error)
      }
      currentMonthSpendings?.remove(at: index)
      calculateTotal()
      spendingToDeleteIndex = nil
    }
  }

  func prepareEdit(spending: SpendingDto) {
    self.spendingToEdit = spending
    self.showAddSheet = true
  }

  private func calculateTotal() {
    guard let currentMonthSpendings = currentMonthSpendings else { return }
    self.totalSpending = currentMonthSpendings.reduce(0) { $0 + Int($1.amount) }
  }

  func getCurrentMonthBudget() {
    let budgetId = "\(AppData.user?.id ?? "")_\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
    Task { @MainActor in
      let result = await budgetService.getMonthlyBudget(id: budgetId)
      if case .data(let budget) = result {
        self.monthlyBudget = budget
      }
    }
  }

  private func fetchAccounts() {
    Task { [weak self] in
      guard let self = self else { return }
      let result = await accountService.getAllAccounts()
      switch result {
      case .data(let data):
        self.accounts = data.filter {!$0.isArchived}
      case .error(let err): self.overlayManager.showToast(message: err, style: .error)
      default: break
      }
    }
  }

}

// MARK: - Spending Filters
extension SpendingsViewModel {
  func updatedSorting() {
    guard let spendings = self.currentMonthSpendings else { return }
    let sortedSpendings = sortSpendings(spendings: spendings)
    self.currentMonthSpendings = sortedSpendings
  }

  private func sortSpendings(spendings: [SpendingDto]) -> [SpendingDto] {
    guard !spendings.isEmpty else { return [] }
    var sortedSpendings = [SpendingDto]()
    switch selectedSortType.id {
    case 0:
      sortedSpendings = spendings.sorted { $0.date > $1.date }
    case 1:
      sortedSpendings = spendings.sorted { $0.amount > $1.amount }
    default:
      return []
    }
    return sortedSpendings
  }

  // MARK: - Search / Filter / Sort Computed Properties
  var availableCategories: [String] {
    guard let spendings = currentMonthSpendings else { return [] }
    return Array(Set(spendings.map { $0.type })).sorted()
  }

  var filteredSpendings: [SpendingDto] {
    guard let spendings = currentMonthSpendings else { return [] }
    var result = applyFilters(to: spendings)
    if !searchText.isEmpty { result = applySearch(to: result) }
    return result.sorted(by: sortOption)
  }

  var budgetProgress: Double {
    let budgetTotal = convertedBudgetAmount
    guard budgetTotal > 0 else { return 0 }
    return Double(totalSpending) / budgetTotal
  }

  private func applyFilters(to spendings: [SpendingDto]) -> [SpendingDto] {
    var result = spendings

    if filters.dateRange != .all {
      let calendar = Calendar.current
      let now = Date()
      result = result.filter { spending in
        switch filters.dateRange {
        case .all: return true
        case .today: return calendar.isDateInToday(spending.date)
        case .last7Days:
          guard let ago = calendar.date(byAdding: .day, value: -7, to: now) else { return true }
          return spending.date >= ago
        case .last14Days:
          guard let ago = calendar.date(byAdding: .day, value: -14, to: now) else { return true }
          return spending.date >= ago
        case .thisWeek:
          return calendar.isDate(spending.date, equalTo: now, toGranularity: .weekOfYear)
        }
      }
    }

    if filters.amountRange != .all {
      result = result.filter { filters.amountRange.matches(amount: $0.amount) }
    }

    if !filters.categories.isEmpty {
      result = result.filter { filters.categories.contains($0.type) }
    }

    if filters.hasProject != .all {
      result = result.filter { spending in
        let hasValidProject = spending.project?.id != nil && !(spending.project?.id?.isEmpty ?? true)
        switch filters.hasProject {
        case .all: return true
        case .withProject: return hasValidProject
        case .withoutProject: return !hasValidProject
        }
      }
    }

    return result
  }

  private func applySearch(to spendings: [SpendingDto]) -> [SpendingDto] {
    let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium

    return spendings.filter { spending in
      if spending.name.lowercased().contains(query) { return true }
      if spending.type.lowercased().contains(query) { return true }
      if String(format: "%.2f", spending.amount).contains(query) { return true }
      if dateFormatter.string(from: spending.date).lowercased().contains(query) { return true }
      if let projectName = spending.project?.projectName?.lowercased(),
         projectName.contains(query) { return true }
      if let currency = spending.currencyCode?.lowercased(),
         currency.contains(query) { return true }
      return false
    }
  }
}
