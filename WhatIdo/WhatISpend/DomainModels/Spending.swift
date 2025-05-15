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
    let typeId: Int
    let categoryId: Int

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.date = try container.decode(Date.self, forKey: .date)
        self.categoryId = try container.decode(Int.self, forKey: .categoryId)
        self.typeId = try container.decode(Int.self, forKey: .typeId)
    }

    init(name: String, amount: Double, date: Date, categoryId: Int, typeId: Int) {
        self.name = name
        self.amount = amount
        self.date = date
        self.categoryId = categoryId
        self.typeId = typeId
    }

    public static func == (lhs: Spending, rhs: Spending) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

     func convertToDto() -> SpendingDto {
         
        return SpendingDto(id: self.id, name: self.name, amount: self.amount, date: self.date, type: "")
    }

}

