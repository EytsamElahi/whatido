//
//  CategoryChartData.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//

import SwiftUI

struct SpendingTypeChartData: Identifiable, Hashable {
    var id: String { spendingName }
    let spendingName: String
    let icon: String
    let totalAmount: Double
    let color: Color
    let transactions: [SpendingDto]
}

// Time Filter ke liye Enum
enum TimeRange: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case allTime = "All Time"
}
