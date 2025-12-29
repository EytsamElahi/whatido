//
//  AnalyticsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//

import SwiftUI
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    
    // Services
    private let spendingService: SpendingsServiceProtocol

    // Data
    @Published var spendings: [SpendingDto] = []
    @Published var chartData: [SpendingTypeChartData] = []
    @Published var selectedRange: TimeRange = .thisMonth
    @Published var totalSpent: Double = 0.0
    
    @Published var isLoading = false
    init(service: SpendingsServiceProtocol = SpendingsService()) {
        self.spendingService = service
    }

    // Filter trigger
    func fetchAnalytics() {
        self.isLoading = true
        
        Task {
            // NOTE: Asal app mein aap Date Range ke hisaab se DB query karoge.
            // Abhi ke liye hum saara data la kar filter kar rahe hain (Simple logic)
            let result = await spendingService.getAllSpendings() // Ya getSpendingsByDate()
            
            if case .data(let allSpendings) = result {
                self.filterAndProcessData(allSpendings)
            }
            
            self.isLoading = false
        }
    }
    
    // Main Logic: Raw Data -> Chart Data
    private func filterAndProcessData(_ allData: [SpendingDto]) {
        var filteredData: [SpendingDto] = []

        // 1. Filter by Date
        let calendar = Calendar.current
        let now = Date()

        switch selectedRange {
        case .thisWeek:
            filteredData = allData.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        case .thisMonth:
            filteredData = allData.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .allTime:
            filteredData = allData
        }

        self.spendings = filteredData

        // 2. Calculate Total
        self.totalSpent = filteredData.reduce(0) { $0 + $1.amount }

        // 3. Group by Category
        // Dictionary banayenge: ["Food": 500, "Fuel": 200]
        let groupedDict = Dictionary(grouping: filteredData, by: { $0.type }) // 'type' is category name

        // Dictionary ko ChartData Array mein convert karein
        var processedData: [SpendingTypeChartData] = []

        for (categoryName, spendings) in groupedDict {
            let total = spendings.reduce(0) { $0 + $1.amount }

            // 🔥 CRITICAL FIX: Agar amount 0 ya minus hai to chart mein mat add karo
            if total > 0.01 { // 0 ki jagah 0.01 check karein (Floating point safety)
                if let firstItem = spendings.first {
                    processedData.append(SpendingTypeChartData(
                        spendingName: categoryName,
                        icon: firstItem.icon,
                        totalAmount: total,
                        color: firstItem.iconColor
                    ))
                }
            }
        }

        // Sort: Sabse zyada kharcha upar
        let sortedData = processedData.sorted { $0.totalAmount > $1.totalAmount }
        self.chartData = sortedData
    }
}
