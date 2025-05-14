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
    @Published var spendingItemTf: String = ""
    @Published var amountTf: String = ""
    @Published var dateTf: String = ""
    @Published var spendingTypeName: String = "" {
        didSet {
            spendingType = spendingTypes.first(where: {$0.name == self.spendingTypeName})
        }
    }
    @Published var spendingTypes: [SpendingType] = []
    private var spendingType: SpendingType?

    //MARK: - State Members
    @Published var showAddNewSpendingSheet: Bool = false

    init() {
        loadSpendingTypes()
    }

    var spendingService: WhatISpendServiceType = WhatISpendService()

    private func loadSpendingTypes() {
        let types: [SpendingType] = Helper.load("spending_types.json")
        self.spendingTypes = types
    }
}

// MARK: - Add New Spending
extension SpendingsViewModel {
    func addSpending() {
        let date = dateTf.toTimeStamp(format: "MM/dd/yyyy")
        guard let spendingType = spendingType else {return}
        newSpending = Spending(name: spendingItemTf, amount: Double(amountTf) ?? 0.0, date: date ?? Date(), categoryId: spendingType.catId ?? -1, typeId: spendingType.id ?? -1)
        guard let spending = newSpending else {
            showAddNewSpendingSheet = false
            return
        }
        Task {
            try await spendingService.addNewSpending(spending)
        }
    }
}

