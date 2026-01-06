//
//  Account.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//


import Foundation

//
// MARK: - Account Domain Model
//
class Account: FirestoreIdentifiable {
    var id: String = ""
    let userId: String
    let name: String
    let type: String       // Stored as String in DB
    let currentBalance: Double
    let currency: String
    let sourceId: String

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.currentBalance = try container.decode(Double.self, forKey: .currentBalance)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.sourceId = try container.decode(String.self, forKey: .sourceId)
    }

    init(name: String, type: AccountType, balance: Double, currency: String, sourceId: String) {
        self.name = name
        self.type = type.rawValue
        self.currentBalance = balance
        self.currency = currency
        self.userId = AppData.user?.id ?? ""
        self.sourceId = sourceId
    }

    func convertToDto() -> AccountDto {
        return AccountDto(
            id: self.id,
            name: self.name,
            type: AccountType(rawValue: self.type) ?? .cash,
            currentBalance: self.currentBalance,
            currency: self.currency,
            sourceId: self.sourceId
        )
    }

    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
// MARK: - Income Source Domain Model
//
class IncomeSource: FirestoreIdentifiable {
    var id: String = ""
    let userId: String
    let name: String

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }

    init(name: String) {
        self.name = name
        self.userId = AppData.user?.id ?? ""
    }

    func convertToDto() -> IncomeSourceDto {
        return IncomeSourceDto(
            id: self.id,
            name: self.name,
            icon: IncomeSource.getAutoIcon(forName: self.name)
        )
    }

    public static func == (lhs: IncomeSource, rhs: IncomeSource) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension IncomeSource {
    static func getAutoIcon(forName name: String) -> String {
        let n = name.lowercased()

        // 1. Job / Salary
        if n.contains("salary") || n.contains("job") || n.contains("employment") || n.contains("wages") {
            return "briefcase.fill"
        }

        // 2. Freelancing / Tech
        if n.contains("freelanc") || n.contains("upwork") || n.contains("fiverr") || n.contains("dev") || n.contains("tech") || n.contains("project") {
            return "laptopcomputer"
        }

        // 3. Property / Rent
        if n.contains("rent") || n.contains("property") || n.contains("house") || n.contains("airbnb") || n.contains("real estate") {
            return "house.fill"
        }

        // 4. Gifts / Bonus
        if n.contains("gift") || n.contains("bonus") || n.contains("eidi") || n.contains("birthday") {
            return "gift.fill"
        }

        // 5. Investments / Profit
        if n.contains("stock") || n.contains("crypto") || n.contains("profit") || n.contains("dividend") || n.contains("invest") {
            return "chart.line.uptrend.xyaxis"
        }

        // 6. Family / Pocket Money
        if n.contains("dad") || n.contains("mom") || n.contains("pocket") || n.contains("family") {
            return "figure.2.and.child.holdinghands"
        }

        // Default Fallback (General Money)
        return "banknote.fill"
    }
}
