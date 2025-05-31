//
//  Budget.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import Foundation

class Budget: FirestoreIdentifiable {
    var id: String = ""
    let month: String
    let year: Int
    let budgetAmount: Double
    let created: Date?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.budgetAmount = try container.decode(Double.self, forKey: .budgetAmount)
        self.created = try container.decode(Date.self, forKey: .created)
        self.month = try container.decode(String.self, forKey: .month)
        self.year = try container.decode(Int.self, forKey: .year)
    }

    init(
        month: String,
        year: Int,
        budgetAmount: Double
    ) {
        self.month = month
        self.budgetAmount = budgetAmount
        self.year = year
        self.created = nil
    }

    public static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
