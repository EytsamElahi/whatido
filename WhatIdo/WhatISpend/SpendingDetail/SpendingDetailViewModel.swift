//
//  SpendingDetailViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/06/2025.
//

import Foundation

class SpendingDetailViewModel: BaseViewModel {
    // MARK: - Data Members
    @Published var pieChartData: [PieChartModel]?

    var spendingService: WhatISpendServiceType
    var currentMonthSpendings: [SpendingDto]?
    var spendingTypes: [SpendingType]?
    var spendingCategories: [SpendingCategory]?

    init(spendingService: WhatISpendServiceType, currentMonthSpendings: [SpendingDto]? = nil, spendingTypes: [SpendingType]? = nil) {
        self.spendingService = spendingService
        self.currentMonthSpendings = currentMonthSpendings
        self.spendingTypes = spendingTypes
        super.init()
        loadSpendingCategories()
    }

    private func loadSpendingCategories() {
        let categories: [SpendingCategory] = Helper.load("spending_categories.json")
        self.spendingCategories = categories
    }

    func generatePieChartData() {
        guard let spendingCategories = self.spendingCategories, let spendings = currentMonthSpendings else {
            return
        }
        var pieChartData = [PieChartModel]()
        for spending in spendings {
            let piechartIds = pieChartData.map { $0.id }
            if piechartIds.contains(spending.spendingCategoryId) {
                if let index = pieChartData.firstIndex(where: {$0.id == spending.spendingCategoryId}) {
                    pieChartData[index].value += spending.amount
                }
            } else {
                let categoryName = spendingCategories.first(where: {$0.id == spending.spendingCategoryId})?.name ?? ""
                pieChartData.append(PieChartModel(id: spending.spendingCategoryId, name: categoryName, value: spending.amount))
            }
        }
        debugPrint(pieChartData)
        DispatchQueue.main.async {
            self.pieChartData = pieChartData

        }
    }

}
