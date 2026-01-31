//
//  FeedbackViewModel.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import Foundation
import OSLog

@MainActor
final class FeedbackViewModel: ObservableObject {
  @Published var feedbackText: String = ""
  @Published var rating: Int = 0
  @Published var selectedCategory: FeedbackCategory = .generalFeedback
  @Published var isLoading: Bool = false
  @Published var shouldDismiss: Bool = false

  private let feedbackService: FeedbackServiceProtocol
  private let overlayManager = OverlayManager.shared
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "",
    category: "FeedbackViewModel"
  )

  var isValid: Bool {
    feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10 &&
    rating > 0
  }

  var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version) (\(build))"
  }

  init(feedbackService: FeedbackServiceProtocol) {
    self.feedbackService = feedbackService
  }

  func submitFeedback() {
    guard isValid else { return }

    isLoading = true

    Task { [weak self] in
      guard let self = self else { return }

      let feedback = Feedback(
        feedbackText: feedbackText.trimmingCharacters(in: .whitespacesAndNewlines),
        rating: rating,
        category: selectedCategory,
        appVersion: appVersion
      )

      let result = await feedbackService.submitFeedback(feedback)

      isLoading = false

      switch result {
      case .data:
        logger.info("Feedback submitted successfully")
        overlayManager.showToast(message: "Thank you for your feedback!", style: .success)
        shouldDismiss = true
      case .error(let message):
        logger.error("Failed to submit feedback: \(message)")
        overlayManager.showToast(message: "Failed to submit feedback", style: .error)
      case .success:
        break
      }
    }
  }
}
