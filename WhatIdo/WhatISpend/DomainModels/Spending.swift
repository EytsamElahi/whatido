//
//  Spending.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

class Spending: FirestoreIdentifiable {
    var id: String = ""
    let name: String
    let amount: Double
    let date: Date
    let spendingType: SpendingType?
    let created: Date?
    let updated: Date?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.date = try container.decode(Date.self, forKey: .date)
        self.spendingType = try container.decodeIfPresent(SpendingType.self, forKey: .spendingType)
        self.created = try container.decodeIfPresent(Date.self, forKey: .created)
        self.updated = try container.decodeIfPresent(Date.self, forKey: .updated)
    }

    init(name: String, amount: Double, date: Date, spendingType: SpendingType?, created: Date) {
        self.name = name
        self.amount = amount
        self.date = date
        self.spendingType = spendingType
        self.updated = nil
        self.created = created
    }

    public static func == (lhs: Spending, rhs: Spending) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

     func convertToDto() -> SpendingDto {
         
         return SpendingDto(id: self.id, name: self.name, amount: self.amount, date: self.date, type: self.spendingType?.name ?? "", created: self.created ?? Date())
    }

}

// 'D' indicates for domain model
class DSpendingType: FirestoreIdentifiable {
    var id: String = ""
    let name: String

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    public static func == (lhs: DSpendingType, rhs: DSpendingType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
