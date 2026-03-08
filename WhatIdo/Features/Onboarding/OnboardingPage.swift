//
//  OnboardingPage.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import Foundation

struct OnboardingPage: Identifiable {
  let id: Int
  let title: String
  let subtitle: String
  let iconName: String
  let isLastPage: Bool

  var progressText: String? {
    guard !isLastPage && id > 0 else { return nil }
    return "\(id)/4"
  }
}

extension OnboardingPage {
  static let pages: [OnboardingPage] = [
    OnboardingPage(
      id: 0,
      title: "Welcome to Yaru",
      subtitle: "Your personal finance companion.\nTrack smarter. Spend wiser.",
      iconName: "sparkles",
      isLastPage: false
    ),
    OnboardingPage(
      id: 1,
      title: "Track Every Expense",
      subtitle: "Record spending with categories, dates, and funding sources in seconds.",
      iconName: "creditcard.fill",
      isLastPage: false
    ),
    OnboardingPage(
      id: 2,
      title: "Organize by Projects",
      subtitle: "Group expenses for trips, renovations, or any goal. Track what matters most.",
      iconName: "folder.fill.badge.gearshape",
      isLastPage: false
    ),
    OnboardingPage(
      id: 3,
      title: "Stay Within Budget",
      subtitle: "Set monthly budgets, view spending analytics, and track progress with beautiful charts.",
      iconName: "chart.pie.fill",
      isLastPage: false
    ),
    OnboardingPage(
      id: 4,
      title: "Works Globally",
      subtitle: "Track expenses in 7 currencies with live exchange rates. Your money, any currency.",
      iconName: "globe.americas.fill",
      isLastPage: true
    )
  ]
}
