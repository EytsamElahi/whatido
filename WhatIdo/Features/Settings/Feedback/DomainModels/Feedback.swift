//
//  Feedback.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import Foundation

final class Feedback: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let feedbackText: String
  let rating: Int
  let category: String
  let appVersion: String
  let created: Date?
  let updated: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case userId
    case feedbackText
    case rating
    case category
    case appVersion
    case created
    case updated
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
    self.userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
    self.feedbackText = try container.decode(String.self, forKey: .feedbackText)
    self.rating = try container.decode(Int.self, forKey: .rating)
    self.category = try container.decode(String.self, forKey: .category)
    self.appVersion = try container.decode(String.self, forKey: .appVersion)
    self.created = try container.decodeIfPresent(Date.self, forKey: .created)
    self.updated = try container.decodeIfPresent(Date.self, forKey: .updated)
  }

  init(
    id: String = "",
    feedbackText: String,
    rating: Int,
    category: FeedbackCategory,
    appVersion: String
  ) {
    self.id = id
    self.userId = AppData.user?.id ?? ""
    self.feedbackText = feedbackText
    self.rating = rating
    self.category = category.rawValue
    self.appVersion = appVersion
    self.created = nil
    self.updated = nil
  }

  static func == (lhs: Feedback, rhs: Feedback) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
