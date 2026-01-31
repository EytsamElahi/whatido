//
//  FeedbackService.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import Foundation
import FirebaseAnalytics
import OSLog

protocol FeedbackServiceProtocol {
  func submitFeedback(_ feedback: Feedback) async -> AppResult<Feedback>
}

final class FeedbackService: FirebaseService, FeedbackServiceProtocol {
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "",
    category: "FeedbackService"
  )

  func submitFeedback(_ feedback: Feedback) async -> AppResult<Feedback> {
    do {
      let result: Feedback = try await post(
        data: feedback,
        endpoint: FirestoreEndpoints.createFeedback
      )
      logAnalyticsEvent(feedback: feedback)
      logger.info("Feedback submitted successfully")
      return .data(result)
    } catch {
      logger.error("Failed to submit feedback: \(error.localizedDescription)")
      return .error(error.localizedDescription)
    }
  }

  private func logAnalyticsEvent(feedback: Feedback) {
    Analytics.logEvent("beta_feedback_submitted", parameters: [
      "category": feedback.category,
      "rating": feedback.rating,
      "app_version": feedback.appVersion
    ])
  }
}
