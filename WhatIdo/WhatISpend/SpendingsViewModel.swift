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
    @Published var isDataUploading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var showConfirmationAlert: Bool = false
    var tempSpending: SpendingDto? // In case of edit
    var spendingToDelete: SpendingDto? // Temporarily holding to be deleting spending

    init() {
        loadSpendingTypes()
    }

    var spendingService: WhatISpendServiceType = WhatISpendService()

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
            self.tempSpending = nil
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
            self.fetchSpendings()

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
            try await spendingService.addNewSpending(spending)
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
            self.fetchSpendings()
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
        let spendingsToDelete = offsets.map { spendings?[$0] }
        guard let firstSpending = spendingsToDelete.first else {return}
        guard let spending = firstSpending else {return}
        self.spendingToDelete = spending
        showConfirmationAlert = true
        
    }
    
    func confirmedDeleteSpending() {
        guard let spending = spendingToDelete else {return}
        Task {@MainActor in
            try await spendingService.deleteSpending(spending.id)
            self.spendings?.removeAll {$0.id == spending.id}
            self.totalSpending = self.spendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.spendingToDelete = nil
        }
    }
}
