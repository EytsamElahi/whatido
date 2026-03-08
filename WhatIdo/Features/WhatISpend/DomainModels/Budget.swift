//
//  Budget.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import Foundation

class Budget: FirestoreIdentifiable, AppDataType {
    var id: String = ""
    let month: String
    let year: Int
    var budgetAmount: Double
    let created: Date?
    let userId: String
    var currencyCode: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.budgetAmount = try container.decode(Double.self, forKey: .budgetAmount)
        self.created = try container.decode(Date.self, forKey: .created)
        self.month = try container.decode(String.self, forKey: .month)
        self.year = try container.decode(Int.self, forKey: .year)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
    }

    init(
        month: String,
        year: Int,
        budgetAmount: Double,
        currencyCode: String? = nil
    ) {
        self.month = month
        self.budgetAmount = budgetAmount
        self.year = year
        self.created = nil
        self.userId = AppData.user?.id ?? ""
        self.currencyCode = currencyCode
    }

    public static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
