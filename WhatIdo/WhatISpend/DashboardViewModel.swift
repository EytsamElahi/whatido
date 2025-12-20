//
//  DashboardViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    // Services
    private let spendingService: SpendingsServiceProtocol
    private let budgetService: BudgetsServiceProtocol
    
    // MARK: - Data
    @Published var currentMonthSpendings: [SpendingDto]?
    @Published var totalSpending: Int = 0
    @Published var monthlyBudget: Budget?

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

    // Edit State
    var spendingToEdit: SpendingDto? // Isay use kar ke hum TransactionFormViewModel init karenge
    private var cancellables = Set<AnyCancellable>()

    init(spendingService: SpendingsServiceProtocol = SpendingsService(),
         budgetService: BudgetsServiceProtocol = BudgetsService(),
         eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
        self.spendingService = spendingService
        self.budgetService = budgetService

        // 👂 LISTENER (SUBSCRIBER)
        eventBus
            .receive(on: DispatchQueue.main) // UI Update hamesha Main thread par
            .sink { [weak self] _ in
                // Jab bhi signal aye, Data refresh karo!
                print("♻️ Data Change Detected: Refreshing Dashboard...")
                self?.fetchDashboardData()
            }
            .store(in: &cancellables)

    }
    
    // MARK: - Fetch Logic
    func fetchDashboardData() {
        isDataLoading = true
        Task {
            // 1. Fetch Spendings
            let spendingResult = await spendingService.getSpendingsOfMonth(currentMonthDate ?? Date())
            if case .data(let spendings) = spendingResult {
                self.currentMonthSpendings = spendings
                self.calculateTotal()
            }
            
            // 2. Fetch Budget
            let budgetId = "\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
            let budgetResult = await budgetService.getMonthlyBudget(id: budgetId)
            if case .data(let budget) = budgetResult {
                self.monthlyBudget = budget
            } else {
                self.monthlyBudget = nil
            }
            
            isDataLoading = false
        }
    }
    
    func deleteSpending() {
        guard let index = spendingToDeleteIndex else { return }
        guard let spendings = currentMonthSpendings else {return}
        let spending = spendings[index]
        
        Task {
            let result = await spendingService.deleteSpending(spending.id)
            if case(.error(let string)) = result {
                debugPrint("Error in deleting spending \(string)")
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

}

// MARK: - Spending Filters
extension DashboardViewModel {
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
