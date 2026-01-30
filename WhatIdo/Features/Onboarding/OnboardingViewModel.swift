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
  @Published var isOnboardingComplete: Bool = false

  let pages: [OnboardingPage] = OnboardingPage.pages
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "OnboardingViewModel")

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
    guard currentPage < pages.count - 1 else {
      completeOnboarding()
      return
    }
    currentPage += 1
  }

  func skipOnboarding() {
    completeOnboarding()
  }

  func completeOnboarding() {
    AppData.hasCompletedOnboarding = true
    isOnboardingComplete = true
    logger.info("Onboarding completed")
  }
}
