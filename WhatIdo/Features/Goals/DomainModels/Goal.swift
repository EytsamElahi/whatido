//
//  Goal.swift
//  WhatIdo
//
//  Created by Cursor AI on 15/01/2026.
//

import Foundation

final class Goal: FirestoreIdentifiable {
  var id: String = ""
  let title: String
  let targetDate: Date
  let isCompleted: Bool
  let userId: String
  let created: Date?
  let updated: Date?

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.targetDate = try container.decode(Date.self, forKey: .targetDate)
    self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    self.userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
    self.created = try container.decodeIfPresent(Date.self, forKey: .created)
    self.updated = try container.decodeIfPresent(Date.self, forKey: .updated)
  }

  init(
    id: String = "",
    title: String,
    targetDate: Date,
    isCompleted: Bool = false,
    created: Date? = nil,
    updated: Date? = nil
  ) {
    self.id = id
    self.title = title
    self.targetDate = targetDate
    self.isCompleted = isCompleted
    self.created = created
    self.updated = updated
    self.userId = AppData.user?.id ?? ""
  }
    
    public static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

