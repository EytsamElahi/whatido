//
//  SpendingListViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import Foundation

class SpendingsViewModel: ObservableObject {
    // MARK: - Data Members
    @Published var newSpending: Spending?
    @Published var spendings: [SpendingDto]?
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
    private var spendingType: SpendingType?

    //MARK: - State Members
    @Published var showAddNewSpendingSheet: Bool = false
    @Published var isDataLoading: Bool = false
    @Published var showErrorAlert: Bool = false

    init() {
        loadSpendingTypes()
    }

    var spendingService: WhatISpendServiceType = WhatISpendService()

    private func loadSpendingTypes() {
        let types: [SpendingType] = Helper.load("spending_types.json")
        self.spendingTypes = types
    }
}

//MARK: - Fetching spendings
extension SpendingsViewModel {
    func fetchSpendings() {
        isDataLoading = true
        Task {@MainActor in
            self.spendings = try await spendingService.getAllSpendings()
            self.totalSpending = self.spendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.isDataLoading = false
        }
    }

}

// MARK: - Add New Spending
extension SpendingsViewModel {
    func addSpending() {
        guard validateAddSpendingForm() else {
            showErrorAlert = true
            return
        }
        let date = dateTf.toTimeStamp(format: "MM/dd/yyyy")
        guard let spendingType = spendingType else {return}
        newSpending = Spending(name: spendingItemTf, amount: Double(amountTf) ?? 0.0, date: date ?? Date(), categoryId: spendingType.catId ?? -1, typeId: spendingType.id ?? -1, spendingType: spendingType)
        guard let spending = newSpending else {
            return
        }
        Task {@MainActor in
            try await spendingService.addNewSpending(spending)
            self.showAddNewSpendingSheet = false
        }
    }

    private func validateAddSpendingForm() -> Bool {
        guard !spendingItemTf.isEmpty, !amountTf.isEmpty, let _ = dateTf.toTimeStamp(format: "MM/dd/yyyy"), let spendingType = spendingType, spendingType.id != 0 else {
            return false
        }
        return true
    }

    private func resetAddSpendingForm() {
        self.spendingItemTf = ""
        self.amountTf = ""
        self.dateTf = ""
        self.spendingType = nil
    }
}

