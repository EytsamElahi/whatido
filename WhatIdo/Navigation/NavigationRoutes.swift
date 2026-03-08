//
//  NavigationRoutes.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//

enum Route: Hashable {
  case onboarding
  case spendings
  case SpendingDetails
  case projectListing
  case projectSpendingsList(ProjectDto)
  case spendingAnalytics
  case currencySettings(Bool)
  case settings
  case analyticsTest
  case login
  case goals
  case myAccounts
}
