//
//  NavigationRoutes.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//

enum Route: Hashable {
    case spendings
    case SpendingDetails
    case projectListing
    case projectSpendingsList(ProjectDto)
    case spendingAnalytics
    case currencySettings(Bool)
    case settings
    case login
}
