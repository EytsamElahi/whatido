//
//  SpendingListViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import Foundation

class SpendingsViewModel: BaseViewModel {
    // MARK: - Data Members
    @Published var newSpending: Spending?
    @Published var currentMonthSpendings: [SpendingDto]?
    @Published var spendingItemTf: String = ""
    @Published var amountTf: String = ""
    @Published var dateTf: String = ""
    @Published var spendingTypeName: String = "" {
        didSet {
            spendingType = spendingTypes.first(where: {$0.name == self.spendingTypeName})
        }
    }
    @Published var spendingTypes: [SpendingType] = []
    @Published private(set) var totalSpending: Int = 0
    @Published var budgetAmountTf: String = ""
    private(set) var spendingSortTypes: [MenuItem] = [MenuItem(id: 0, name: "Date"), MenuItem(id: 1, name: "Amount")]
    private var spendingType: SpendingType?
    @Published var selectedSortType: MenuItem?
    @Published var allSpendings: [SpendingDto]?
    @Published var allSpendingsMonthYear: [Int: [MonthItem]]?
    @Published var currentMonth: String = Date().getMonthName()
    @Published var currentMonthInDateFormat: Date? = Date().getFirstDateOfMonth()
    @Published var currentMonthBudget: Budget?

    // MARK: - State Members
    @Published var showAddNewSpendingSheet: Bool = false
    @Published var isDataLoading: Bool = false
    @Published var isDataUploading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var showConfirmationAlert: Bool = false
    @Published var fetchingAllSpendings: Bool = false
    @Published var showMoreMonths: Bool = false
    @Published var showBudgetSettingSheet: Bool = false
    var tempSpending: SpendingDto? // In case of edit
    var spendingToDelete: SpendingDto? // Temporarily holding to be deleting spending

    var spendingService: WhatISpendServiceType
    init(spendingService: WhatISpendServiceType) {
        self.spendingService = spendingService
        super.init()
        self.loadSpendingTypes()
        
    }

    private func loadSpendingTypes() {
        let types: [SpendingType] = Helper.load("spending_types.json")
        self.spendingTypes = types
    }

    func addSpendingSheetAction() {
        if tempSpending == nil {
            addSpending()
        } else {
            updateSpending()
        }
    }
}

// MARK: - Fetching spendings
extension SpendingsViewModel {
    func fetchMonthlySpendings(_ month: String, year: Int) {
        if month == self.currentMonth {
            self.showMoreMonths = false
            return
        }
        let existedMonthlySpendings = self.allSpendings?.filter {$0.date.getMonthName() == month }
        self.currentMonth = month
        self.currentMonthInDateFormat = Utilities.dateFrom(monthName: month, year: year)?.getFirstDateOfMonth() ?? Date()
        self.showMoreMonths = false
        self.currentMonthSpendings = existedMonthlySpendings
        self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
    }
    func fetchCurrentMonthSpendings(date: Date? = nil) {
        isDataLoading = true
        guard let firstDateOfCurrentMonth = date else {return}
        Task {@MainActor in
            let spendings = try await spendingService.getSpendingsOfMonth(firstDateOfCurrentMonth)
            self.currentMonthSpendings = spendings
            self.getCurrentMonthBudget()
            self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.isDataLoading = false
        }
    }

    func fetchallSpendings() {
        self.fetchingAllSpendings = true
        Task {@MainActor in
            let spendings = try await spendingService.getAllSpendings()
            let allDates = spendings.compactMap{ $0.date }
            self.allSpendings = spendings
            self.allSpendingsMonthYear = groupDatesToMonthItems(dates: allDates)
            self.fetchingAllSpendings = false
        }
    }

}

// MARK: - Edit Spending
extension SpendingsViewModel {
    func editSpending(_ spending: SpendingDto) {
        self.tempSpending = spending
        self.spendingItemTf = spending.name
        self.amountTf = String(Int(spending.amount))
        self.dateTf = spending.date.toDateReturnString()
        spendingTypeName = spending.type
        self.spendingType = spendingTypes.first { $0.name == spending.type }
        self.showAddNewSpendingSheet = true
    }

    private func updateSpending() {
        isDataUploading = true
        mapDtoToDomainModelAndValidate()
        guard let spending = newSpending else {
            return
        }
        guard let spendingId = tempSpending?.id else {return}
        Task {@MainActor in
            try await spendingService.editSpending(spending, id: spendingId)
            let updatedSpending = try await spendingService.getSpendingById(spendingId)
            if let index = currentMonthSpendings?.firstIndex(where: { $0.id == spendingId }) {
                currentMonthSpendings?[index] = updatedSpending!
            }
            if let index = allSpendings?.firstIndex(where: { $0.id == spendingId }) {
                allSpendings?[index] = updatedSpending!
            }
            self.tempSpending = nil
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
        }
    }
}

// MARK: - Add New Spending
extension SpendingsViewModel {
    private func addSpending() {
        isDataUploading = true
        mapDtoToDomainModelAndValidate()
        guard let spending = newSpending else {
            return
        }
        Task {@MainActor in
           let id = try await spendingService.addNewSpending(spending)
            let recentAddedSpending = try await spendingService.getSpendingById(id)
            self.currentMonthSpendings?.append(recentAddedSpending!)
            self.updatedSorting()
            self.allSpendings?.append(recentAddedSpending!)
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
            self.resetAddSpendingForm()
        }
    }

    private func mapDtoToDomainModelAndValidate() {
        guard validateAddSpendingForm() else {
            showErrorAlert = true
            self.isDataUploading = false
            return
        }
        let date = dateTf.toTimeStamp(format: "MM/dd/yyyy")
        guard let spendingType = spendingType else {return}
        newSpending = Spending(name: spendingItemTf, amount: Double(amountTf) ?? 0.0, date: date ?? Date(), spendingType: spendingType, created: self.tempSpending?.created ?? Date())
    }

    private func validateAddSpendingForm() -> Bool {
        guard !spendingItemTf.isEmpty, !amountTf.isEmpty, let _ = dateTf.toTimeStamp(format: "MM/dd/yyyy"), let spendingType = spendingType, spendingType.id != 0 else {
            return false
        }
        return true
    }

     func resetAddSpendingForm() {
        self.spendingItemTf = ""
        self.amountTf = ""
        self.dateTf = ""
        self.spendingType = nil
         self.spendingTypeName = ""
    }
}

// MARK: - Delete Spending
extension SpendingsViewModel {
    func deleteSpending(at offsets: IndexSet) {
        let spendingsToDelete = offsets.map { currentMonthSpendings?[$0] }
        guard let firstSpending = spendingsToDelete.first else {return}
        guard let spending = firstSpending else {return}
        self.spendingToDelete = spending
        showConfirmationAlert = true
        
    }
    
    func confirmedDeleteSpending() {
        guard let spending = spendingToDelete else {return}
        Task {@MainActor in
            try await spendingService.deleteSpending(spending.id)
            self.currentMonthSpendings?.removeAll {$0.id == spending.id}
            self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.spendingToDelete = nil
        }
    }
}

// MARK: - Filter
extension SpendingsViewModel {
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
       guard let selectedSortType = selectedSortType else {return []}
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

// MARK: - All Spendings Month Split
extension SpendingsViewModel {
    func groupDatesToMonthItems(dates: [Date]) -> [Int: [MonthItem]] {
        var result: [Int: Set<Int>] = [:]
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"

        // Group months (as Int) by year
        for date in dates {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            result[year, default: []].insert(month)
        }

        // Convert month numbers to MonthItem
        var namedResult: [Int: [MonthItem]] = [:]
        for (year, monthSet) in result {
            let sortedMonths = monthSet.sorted()
            let monthItems = sortedMonths.compactMap { month -> MonthItem? in
                var components = DateComponents()
                components.month = month
                components.day = 1
                if let date = calendar.date(from: components) {
                    let monthName = formatter.string(from: date)
                    return MonthItem(month: monthName, year: year)
                }
                return nil
            }
            namedResult[year] = monthItems
        }

        return namedResult
    }
}

// MARK: - Set a budget
extension SpendingsViewModel {
    func setBudget() {
        guard budgetAmountTf.isEmpty == false else { return }
        self.isDataUploading = true
        let budget = Budget(month: self.currentMonth, year: self.currentMonthInDateFormat?.components.year ?? 0, budgetAmount: Double(budgetAmountTf) ?? 0.0)
        AppData.budget = Double(budgetAmountTf) ?? 0.0
        Task {@MainActor in
            try await spendingService.addMonthlyBudget(budget)
            self.isDataUploading = false
            self.showBudgetSettingSheet = false
        }
    }
    func getCurrentMonthBudget() {
        guard AppData.budget == nil else {return}
        let id = "\(currentMonthInDateFormat?.components.year ?? 0)_\(self.currentMonth)"
        Task {@MainActor in
            let budget = try await spendingService.getMonthlyBudget(id: id)
            self.budgetAmountTf = "\(budget?.budgetAmount)"
            AppData.budget = budget?.budgetAmount
        }
    }
}
