//
//  AnalyticsTestView.swift
//  WhatIdo
//
//  Created by Claude on 01/02/2026.
//

import SwiftUI

struct AnalyticsTestView: View {
  @EnvironmentObject var navigation: NavigationManager
  @State private var eventLog: [String] = []
  @State private var selectedProvider: String = "google"

  private let analytics = AnalyticsManager.shared

  var body: some View {
    ZStack {
      Color.appBackground.ignoresSafeArea()

      VStack(spacing: 0) {
        AppHeaderView(title: "Analytics Test", backAction: {
          navigation.pop()
        })

        ScrollView {
          VStack(spacing: 20) {
            debugInfoSection
            userJourneySection
            coreFeatureSection
            engagementSection
            retentionSection
            eventLogSection
          }
          .padding()
        }
      }
    }
    .navigationBarBackButtonHidden()
  }

  // MARK: - Debug Info Section
  private var debugInfoSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Debug Info")

      let info = analytics.debugInfo

      HStack {
        Text("Days Since First Use:")
          .font(.customFont(family: .quicksand, name: .medium, size: .x14))
          .foregroundStyle(.gray)
        Spacer()
        Text("\(info.daysSinceFirstUse)")
          .font(.customFont(family: .quicksand, name: .bold, size: .x14))
          .foregroundStyle(.white)
      }

      HStack {
        Text("Total Expenses Tracked:")
          .font(.customFont(family: .quicksand, name: .medium, size: .x14))
          .foregroundStyle(.gray)
        Spacer()
        Text("\(info.totalExpenses)")
          .font(.customFont(family: .quicksand, name: .bold, size: .x14))
          .foregroundStyle(.white)
      }

      if let firstDate = info.firstUseDate {
        HStack {
          Text("First Use Date:")
            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
            .foregroundStyle(.gray)
          Spacer()
          Text(firstDate, style: .date)
            .font(.customFont(family: .quicksand, name: .bold, size: .x14))
            .foregroundStyle(.white)
        }
      }

      Button {
        analytics.resetAnalyticsData()
        logEvent("Analytics data reset")
      } label: {
        Text("Reset Analytics Data")
          .font(.customFont(family: .quicksand, name: .bold, size: .x14))
          .foregroundStyle(.red)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(Color.red.opacity(0.15))
          .cornerRadius(8)
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - User Journey Section
  private var userJourneySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("User Journey")

      HStack(spacing: 12) {
        eventButton("Signup (Google)") {
          analytics.logUserSignup(provider: "google")
          logEvent("user_signup (google)")
        }

        eventButton("Signup (Apple)") {
          analytics.logUserSignup(provider: "apple")
          logEvent("user_signup (apple)")
        }
      }

      HStack(spacing: 12) {
        eventButton("Onboarding Done") {
          analytics.logOnboardingCompleted()
          logEvent("onboarding_completed")
        }

        eventButton("User Onboarded") {
          analytics.logUserOnboarded()
          logEvent("user_onboarded")
        }
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - Core Features Section
  private var coreFeatureSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Core Features")

      HStack(spacing: 12) {
        eventButton("Expense Added") {
          analytics.logExpenseAdded(category: "Dining Out", amount: 75.0)
          logEvent("expense_added (Dining Out, 50-200)")
        }

        eventButton("Expense Edited") {
          analytics.logExpenseEdited()
          logEvent("expense_edited")
        }
      }

      HStack(spacing: 12) {
        eventButton("Expense Deleted") {
          analytics.logExpenseDeleted()
          logEvent("expense_deleted")
        }

        eventButton("Budget Set") {
          analytics.logBudgetSet(amount: 500.0)
          logEvent("budget_set (200-1000)")
        }
      }

      HStack(spacing: 12) {
        eventButton("Budget Edited") {
          analytics.logBudgetEdited()
          logEvent("budget_edited")
        }

        eventButton("Project Created") {
          analytics.logProjectCreated(icon: "car.fill")
          logEvent("project_created (car.fill)")
        }
      }

      eventButton("Project Completed") {
        analytics.logProjectCompleted()
        logEvent("project_completed")
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - Engagement Section
  private var engagementSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Engagement")

      HStack(spacing: 12) {
        eventButton("Analytics (Week)") {
          analytics.logAnalyticsViewed(timeRange: "week")
          logEvent("analytics_viewed (week)")
        }

        eventButton("Analytics (Month)") {
          analytics.logAnalyticsViewed(timeRange: "month")
          logEvent("analytics_viewed (month)")
        }
      }

      HStack(spacing: 12) {
        eventButton("Analytics (Year)") {
          analytics.logAnalyticsViewed(timeRange: "year")
          logEvent("analytics_viewed (year)")
        }

        eventButton("Settings Opened") {
          analytics.logSettingsOpened()
          logEvent("settings_opened")
        }
      }

      eventButton("Currency Changed") {
        analytics.logCurrencyChanged(from: "USD", to: "EUR")
        logEvent("currency_changed (USD -> EUR)")
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - Retention Section
  private var retentionSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Retention")

      eventButton("App Opened") {
        analytics.logAppOpened()
        logEvent("app_opened (with retention signals)")
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - Event Log Section
  private var eventLogSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        sectionHeader("Event Log")
        Spacer()
        if !eventLog.isEmpty {
          Button("Clear") {
            eventLog.removeAll()
          }
          .font(.customFont(family: .quicksand, name: .medium, size: .x12))
          .foregroundStyle(.gray)
        }
      }

      if eventLog.isEmpty {
        Text("No events logged yet. Tap buttons above to test.")
          .font(.customFont(family: .quicksand, name: .medium, size: .x12))
          .foregroundStyle(.gray)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 20)
      } else {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(eventLog.reversed(), id: \.self) { event in
            HStack(alignment: .top, spacing: 8) {
              Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

              Text(event)
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                .foregroundStyle(.white)
            }
          }
        }
      }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(12)
  }

  // MARK: - Helpers
  private func sectionHeader(_ title: String) -> some View {
    Text(title)
      .font(.customFont(family: .quicksand, name: .bold, size: .x16))
      .foregroundStyle(.white)
  }

  private func eventButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.appPrimaryColor.opacity(0.3))
        .cornerRadius(8)
    }
  }

  private func logEvent(_ event: String) {
    let timestamp = Date().formatted(date: .omitted, time: .standard)
    eventLog.append("[\(timestamp)] \(event)")
  }
}

#Preview {
  AnalyticsTestView()
    .environmentObject(NavigationManager())
}
