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
    private let overlayManager = OverlayManager.shared
    init(service: SpendingsServiceProtocol = SpendingsService()) {
        self.spendingService = service
    }

    // Filter trigger
    func fetchAnalytics() {
        self.isLoading = true
        Task {[weak self] in
            guard let self = self else {return}
            do {
                // This loop stays alive and listens for updates
                for try await allSpendings in spendingService.getAllSpendings() {
                    self.filterAndProcessData(allSpendings)
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.isLoading = false
                    }
                }
            } catch {
                print("Stream error: \(error.localizedDescription)")
                self.overlayManager.showToast(message: error.localizedDescription, style: .error)
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isLoading = false
                }
            }
        }
    }
    
    // Main Logic: Raw Data -> Chart Data
    private func filterAndProcessData(_ allData: [SpendingDto]) {
        var filteredData: [SpendingDto] = []
        // Date Logic
        let calendar = Calendar.current
        let now = Date()

        switch selectedRange {
        case .thisWeek:
            // Matches current Week of Year
            filteredData = allData.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            // Matches current Month
            filteredData = allData.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month)
            }
        case .thisYear:
            // Matches current Year (Replaces All Time)
            filteredData = allData.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
        }
        // Update the list view data source
        self.spendings = filteredData
        // Calculate Total
        self.totalSpent = filteredData.reduce(0) { $0 + $1.amount }
        // Group by Category
        let groupedDict = Dictionary(grouping: filteredData, by: { $0.type })
        // Convert to ChartData
        var processedData: [SpendingTypeChartData] = []
        for (categoryName, spendings) in groupedDict {
            let total = spendings.reduce(0) { $0 + $1.amount }
            if total > 0.01 { // Safety check
                if let firstItem = spendings.first {
                    processedData.append(SpendingTypeChartData(
                        spendingName: categoryName,
                        icon: firstItem.icon,
                        totalAmount: total,
                        color: firstItem.iconColor,
                        transactions: spendings // ✅ Passing the array for the expandable card
                    ))
                }
            }
        }
        // Sort: Highest spending first
        let sortedData = processedData.sorted { $0.totalAmount > $1.totalAmount }
        // Assign to Published property
        self.chartData = sortedData
    }
}
