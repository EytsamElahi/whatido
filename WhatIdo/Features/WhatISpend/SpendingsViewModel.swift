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
    private let accountService: AccountServiceProtocol

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

    // Delete Spending
    @Published var showDeleteConfirmationAlert: Bool = false
    var spendingToDeleteIndex: Int? 

    // Loading State
    @Published var isDataLoading: Bool = false

    private let overlayManager = OverlayManager.shared

    // Edit State
    var spendingToEdit: SpendingDto? // Isay use kar ke hum TransactionFormViewModel init karenge
    private var cancellables = Set<AnyCancellable>()

    init(spendingService: SpendingsServiceProtocol,
         budgetService: BudgetsServiceProtocol,
         accountService: AccountServiceProtocol,
         eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
        self.spendingService = spendingService
        self.budgetService = budgetService
        self.accountService = accountService
        // 👂 LISTENER (SUBSCRIBER)
        eventBus
            .receive(on: DispatchQueue.main) // UI Update hamesha Main thread par
            .sink { [weak self] _ in
                // Jab bhi signal aye, Data refresh karo!
                print("♻️ Data Change Detected: Refreshing Dashboard...")
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
            let budgetId = "\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
            let budgetResult = await budgetService.getMonthlyBudget(id: budgetId)
            if case .data(let budget) = budgetResult {
                self.monthlyBudget = budget
            }
        }
    }
    
    func deleteSpending() {
        guard let index = spendingToDeleteIndex else { return }
        guard let spendings = currentMonthSpendings else {return}
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
        guard let currentMonthSpendings = currentMonthSpendings else {return}
        self.totalSpending = currentMonthSpendings.reduce(0) { $0 + Int($1.amount) }
    }

    func getCurrentMonthBudget() {
        let budgetId = "\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
        Task {@MainActor in
            let result = await budgetService.getMonthlyBudget(id: budgetId)
            switch result {
            case .data(let budget):
                self.monthlyBudget = budget
            case .error(let error):
                debugPrint("Error in fetching budget \(error)")
            case .success:
                debugPrint("No budget found")
            default:
                debugPrint("Default")
            }

        }
    }

    private func fetchAccounts() {
        Task { [weak self] in
            guard let self = self else {return}
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
    // Sorting logic can remain here or move to a helper
    func updatedSorting() {
        guard let spendings = self.currentMonthSpendings else {
            return
        }

        let sortedSpendings = sortSpendings(spendings: spendings)
        self.currentMonthSpendings = sortedSpendings
    }

    private func sortSpendings(spendings: [SpendingDto]) -> [SpendingDto] {
         guard !spendings.isEmpty else {
            return []
         }
      //  guard let selectedSortType = selectedSortType else {return []}
         var sortedSpendings = [SpendingDto]()
         switch selectedSortType.id {
         case 0:
             sortedSpendings = spendings.sorted { (spending1, spending2) -> Bool in
                 return spending1.date > spending2.date
             }
         case 1:
             sortedSpendings = spendings.sorted { (spending1, spending2) -> Bool in
                 return spending1.amount > spending2.amount
             }
         default:
             return []
         }
         return sortedSpendings
     }
}
