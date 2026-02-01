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
    @Published var totalSpending: Double = 0
    @Published var monthlyBudget: Budget?
    @Published var hasForeignTransaction: Bool = false

    var convertedBudgetAmount: Double {
        guard let budget = monthlyBudget else { return 0 }
        let budgetCurrency = budget.currencyCode ?? "USD"
        let homeCurrency = CurrencyManager.shared.activeCurrency.code
        
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
        return (budget.currencyCode ?? "USD") != CurrencyManager.shared.activeCurrency.code
    }

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
    var spendingToDelete: SpendingDto? 

    // Loading State
    @Published var isDataLoading: Bool = false

    private let overlayManager = OverlayManager.shared
    private let analytics = AnalyticsManager.shared

    // Edit State
    var spendingToEdit: SpendingDto? // Isay use kar ke hum TransactionFormViewModel init karenge
    private var cancellables = Set<AnyCancellable>()
    private var fetchTask: Task<Void, Never>?

    deinit {
        print("🗑️ DashboardViewModel deinitialized: Cleaning up...")
        fetchTask?.cancel()
    }

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
                self?.calculateTotal()
                self?.fetchDashboardData()
            }
            .store(in: &cancellables)

    }
    
    // MARK: - Fetch Logic
    func fetchDashboardData() {
        isDataLoading = true
        analytics.logAppOpened()

        fetchTask?.cancel()
        
        // 1. Fetch Spendings (Stream)
        fetchTask = Task {[weak self] in
            do {
                // This loop stays alive and listens for updates
                // Using .getSpendingsOfMonth which returns AsyncThrowingStream
                let stream: AsyncThrowingStream<[SpendingDto], Error> = spendingService.getSpendingsOfMonth(self?.currentMonthDate ?? Date())
                
                for try await spendings in stream {
                    guard let self = self else { break }
                    
                    self.currentMonthSpendings = spendings
                    self.calculateTotal()
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.isDataLoading = false
                    }
                }
            } catch {
                guard let self = self, !Task.isCancelled else { return }
                
                // Ignore "Missing or insufficient permissions" if we are logging out/deleting
                let errorMsg = error.localizedDescription
                if errorMsg.contains("insufficient permissions") {
                    print("ℹ️ Suppressing permission error during logout/cleanup.")
                    return
                }
                
                print("Stream error: \(errorMsg)")
                self.overlayManager.showToast(message: errorMsg, style: .error)
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isDataLoading = false
                }
            }
        }
           
        // 2. Fetch Budget (Async Request)
        Task {[weak self] in
            guard let self = self else {return}
            let userId = AppData.user?.id ?? ""
            let budgetId = "\(userId)_\(self.currentMonthDate?.components.year ?? 0)_\(self.currentMonth)"
            let budgetResult = await self.budgetService.getMonthlyBudget(id: budgetId)
            
            guard !Task.isCancelled else { return }
            
            if case .data(let budget) = budgetResult {
                self.monthlyBudget = budget
            }
        }
    }
    
    func deleteSpending() {
        guard let spending = spendingToDelete else { return }

        Task {[weak self] in
            guard let self = self else {return}
            let result = await spendingService.deleteSpending(spending.id)
            if case .success = result {
                self.analytics.logExpenseDeleted()
                self.overlayManager.showToast(message: "Spending deleted successfully", style: .success)
            }
            if case(.error(let string)) = result {
                self.overlayManager.showToast(message: string, style: .error)
            }
            spendingToDelete = nil
        }
    }

    
    func prepareEdit(spending: SpendingDto) {
        self.spendingToEdit = spending
        self.showAddSheet = true
    }
    
    private func calculateTotal() {
        guard let currentMonthSpendings = currentMonthSpendings else { return }
        let homeCurrency = CurrencyManager.shared.activeCurrency.code
        debugPrint("Home Currency \(homeCurrency)")
        // 1. Convert everything to USD (Base) and sum it up
        let totalInUSD = currentMonthSpendings.reduce(0.0) { sum, spending in
            let txnCurrency = spending.currencyCode ?? "USD"
            debugPrint("Transaction Currency \(txnCurrency)")
            let rateToUSD = CurrencyConfig.rates[txnCurrency] ?? 1.0
            debugPrint("USD Rate \(rateToUSD)")
            let amountInUSD = spending.amount / rateToUSD
            debugPrint("USD Amount \(amountInUSD)")
            debugPrint("Total \(sum + amountInUSD)")
            return sum + amountInUSD
        }
        
        // 2. Convert final USD sum to User's Home Currency
        let homeRate = CurrencyConfig.rates[homeCurrency] ?? 1.0
        self.totalSpending = totalInUSD * homeRate
        
        // 3. Mixed Currency Check
        self.hasForeignTransaction = currentMonthSpendings.contains { ($0.currencyCode ?? "USD") != homeCurrency }
    }

    func getCurrentMonthBudget() {
        let budgetId = "\(currentMonthDate?.components.year ?? 0)_\(currentMonth)"
        Task {[weak self] in
            guard let self = self else {return}
            let result = await budgetService.getMonthlyBudget(id: budgetId)
            switch result {
            case .data(let budget):
                self.monthlyBudget = budget
            case .error(let error):
                debugPrint("Error in fetching budget \(error)")
            case .success:
                debugPrint("No budget found")
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
