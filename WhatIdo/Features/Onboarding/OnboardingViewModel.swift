//
//  OnboardingViewModel.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import Foundation
import OSLog

@MainActor
class OnboardingViewModel: ObservableObject {
  @Published var currentPage: Int = 0
  @Published var showSignInSheet: Bool = false
  @Published var shouldNavigateToLogin: Bool = false

  let pages: [OnboardingPage] = OnboardingPage.pages
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "OnboardingViewModel")
  private let analytics = AnalyticsManager.shared

  var isFirstPage: Bool {
    currentPage == 0
  }

  var isLastPage: Bool {
    currentPage == pages.count - 1
  }

  var currentPageData: OnboardingPage {
    pages[currentPage]
  }

  func nextPage() {
    if currentPage < pages.count - 1 {
      currentPage += 1
    } else {
      // On last page, show sign-in sheet
      showSignInSheet = true
      // Mark complete in background to avoid blocking UI
      Task.detached(priority: .background) {
        await MainActor.run {
          AppData.hasCompletedOnboarding = true
        }
      }
      analytics.logOnboardingCompleted()
      logger.info("Onboarding marked as complete")
    }
  }

  func skipOnboarding() {
    AppData.hasCompletedOnboarding = true
    shouldNavigateToLogin = true
    logger.info("Onboarding skipped, navigating to login")
  }
}
