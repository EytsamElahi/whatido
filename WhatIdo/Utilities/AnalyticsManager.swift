//
//  AnalyticsManager.swift
//  WhatIdo
//
//  Created by Claude on 01/02/2026.
//

import Foundation
import FirebaseAnalytics
import OSLog

// MARK: - Analytics Event Names
enum AnalyticsEvent: String {
  // User Journey
  case userSignup = "user_signup"
  case onboardingCompleted = "onboarding_completed"
  case userOnboarded = "user_onboarded"

  // Core Features
  case expenseAdded = "expense_added"
  case expenseEdited = "expense_edited"
  case expenseDeleted = "expense_deleted"
  case budgetSet = "budget_set"
  case budgetEdited = "budget_edited"
  case projectCreated = "project_created"
  case projectCompleted = "project_completed"

  // Engagement
  case analyticsViewed = "analytics_viewed"
  case currencyChanged = "currency_changed"
  case settingsOpened = "settings_opened"

  // Retention
  case appOpened = "app_opened"
}

// MARK: - Analytics Parameter Keys
enum AnalyticsParam: String {
  // User Journey
  case provider = "provider"

  // Expense
  case category = "category"
  case amountRange = "amount_range"
  // case fundSource = "fund_source" // disabled — source field removed from UI

  // Project
  case icon = "icon"

  // Analytics
  case timeRange = "time_range"

  // Currency
  case fromCurrency = "from_currency"
  case toCurrency = "to_currency"

  // Retention
  case daysSinceFirstUse = "days_since_first_use"
  case totalExpensesCount = "total_expenses_count"
}

// MARK: - Amount Range Helper
enum AmountRange: String {
  case micro = "0-10"
  case small = "10-50"
  case medium = "50-200"
  case large = "200-1000"
  case extraLarge = "1000+"

  static func from(amount: Double) -> String {
    switch amount {
    case 0..<10:
      return AmountRange.micro.rawValue
    case 10..<50:
      return AmountRange.small.rawValue
    case 50..<200:
      return AmountRange.medium.rawValue
    case 200..<1000:
      return AmountRange.large.rawValue
    default:
      return AmountRange.extraLarge.rawValue
    }
  }
}

// MARK: - Analytics Manager
final class AnalyticsManager {
  static let shared = AnalyticsManager()

  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "Analytics")

  // Session-level flag to prevent duplicate app_opened events
  private var hasLoggedAppOpenedThisSession = false

  // User tracking data
  @AppStorage(key: "analytics_first_use_date", defaultValue: nil)
  private static var firstUseDate: Date?

  @AppStorage(key: "analytics_total_expenses", defaultValue: 0)
  private static var totalExpensesCount: Int

  private init() {
    // Set first use date if not already set
    if AnalyticsManager.firstUseDate == nil {
      AnalyticsManager.firstUseDate = Date()
    }
  }

  // MARK: - Core Logging Method
  func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
    var enrichedParams = parameters ?? [:]

    // Add retention signals for app_opened
    if event == .appOpened {
      enrichedParams[AnalyticsParam.daysSinceFirstUse.rawValue] = daysSinceFirstUse
      enrichedParams[AnalyticsParam.totalExpensesCount.rawValue] = AnalyticsManager.totalExpensesCount
    }

    Analytics.logEvent(event.rawValue, parameters: enrichedParams.isEmpty ? nil : enrichedParams)
    logger.info("📊 Event: \(event.rawValue) | Params: \(String(describing: enrichedParams))")
  }

  // MARK: - User Journey Events
  func logUserSignup(provider: String) {
    logEvent(.userSignup, parameters: [
      AnalyticsParam.provider.rawValue: provider
    ])
  }

  func logOnboardingCompleted() {
    logEvent(.onboardingCompleted)
  }

  func logUserOnboarded() {
    logEvent(.userOnboarded)
  }

  // MARK: - Expense Events
  func logExpenseAdded(category: String, amount: Double) {
    AnalyticsManager.totalExpensesCount += 1

    logEvent(.expenseAdded, parameters: [
      AnalyticsParam.category.rawValue: category,
      AnalyticsParam.amountRange.rawValue: AmountRange.from(amount: amount)
      // AnalyticsParam.fundSource.rawValue: fundSource // disabled
    ])

    // Check if this is the first expense (user_onboarded)
    if AnalyticsManager.totalExpensesCount == 1 {
      logUserOnboarded()
    }
  }

  func logExpenseEdited() {
    logEvent(.expenseEdited)
  }

  func logExpenseDeleted() {
    logEvent(.expenseDeleted)
  }

  // MARK: - Budget Events
  func logBudgetSet(amount: Double) {
    logEvent(.budgetSet, parameters: [
      AnalyticsParam.amountRange.rawValue: AmountRange.from(amount: amount)
    ])
  }

  func logBudgetEdited() {
    logEvent(.budgetEdited)
  }

  // MARK: - Project Events
  func logProjectCreated(icon: String) {
    logEvent(.projectCreated, parameters: [
      AnalyticsParam.icon.rawValue: icon
    ])
  }

  func logProjectCompleted() {
    logEvent(.projectCompleted)
  }

  // MARK: - Engagement Events
  func logAnalyticsViewed(timeRange: String) {
    logEvent(.analyticsViewed, parameters: [
      AnalyticsParam.timeRange.rawValue: timeRange
    ])
  }

  func logCurrencyChanged(from: String, to: String) {
    logEvent(.currencyChanged, parameters: [
      AnalyticsParam.fromCurrency.rawValue: from,
      AnalyticsParam.toCurrency.rawValue: to
    ])
  }

  func logSettingsOpened() {
    logEvent(.settingsOpened)
  }

  // MARK: - Retention Events
  func logAppOpened() {
    guard !hasLoggedAppOpenedThisSession else { return }
    hasLoggedAppOpenedThisSession = true
    logEvent(.appOpened)
  }

  /// Call this when app returns from background to allow new app_opened event
  func resetSessionFlag() {
    hasLoggedAppOpenedThisSession = false
  }

  // MARK: - Helpers
  private var daysSinceFirstUse: Int {
    guard let firstDate = AnalyticsManager.firstUseDate else { return 0 }
    let days = Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
    return max(0, days)
  }

  // MARK: - Debug Helpers
  func resetAnalyticsData() {
    AnalyticsManager.firstUseDate = Date()
    AnalyticsManager.totalExpensesCount = 0
    logger.info("📊 Analytics data reset")
  }

  var debugInfo: (daysSinceFirstUse: Int, totalExpenses: Int, firstUseDate: Date?) {
    (daysSinceFirstUse, AnalyticsManager.totalExpensesCount, AnalyticsManager.firstUseDate)
  }
}
