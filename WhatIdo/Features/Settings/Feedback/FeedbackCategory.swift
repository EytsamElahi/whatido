//
//  FeedbackCategory.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import Foundation

enum FeedbackCategory: String, CaseIterable, Codable {
  case bugReport = "Bug Report"
  case featureRequest = "Feature Request"
  case generalFeedback = "General Feedback"

  var displayName: String {
    rawValue
  }
}
