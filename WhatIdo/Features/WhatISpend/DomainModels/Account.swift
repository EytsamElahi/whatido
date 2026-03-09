//
//  Account.swift
//  WhatIdo
//

import Foundation

//
// MARK: - Account Domain Model
//

class Account: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let name: String
  let type: String
  let openingBalance: Double
  // Cached balance — source of truth is AccountTransaction ledger
  // Firestore field key stays "currentBalance" for backward compatibility
  let cachedBalance: Double
  let currency: String
  let sourceId: String?
  let isArchived: Bool
  let created: Date?
  let isDefault: Bool
  let lastTransactionAt: Date?

  // MARK: - Decodable Implementation
  required init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.userId            = try c.decode(String.self, forKey: .userId)
    self.id                = try c.decode(String.self, forKey: .id)
    self.name              = try c.decode(String.self, forKey: .name)
    self.type              = try c.decode(String.self, forKey: .type)
    self.openingBalance    = try c.decode(Double.self, forKey: .openingBalance)
    self.cachedBalance     = try c.decodeIfPresent(Double.self, forKey: .cachedBalance) ?? 0
    self.currency          = try c.decode(String.self, forKey: .currency)
    self.sourceId          = try c.decodeIfPresent(String.self, forKey: .sourceId)
    self.isArchived        = try c.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    self.created           = try c.decodeIfPresent(Date.self, forKey: .created)
    self.isDefault         = try c.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    self.lastTransactionAt = try c.decodeIfPresent(Date.self, forKey: .lastTransactionAt)
  }

  // CodingKeys must map cachedBalance → "currentBalance"
  enum CodingKeys: String, CodingKey {
    case id, userId, name, type, openingBalance, currency, sourceId, isArchived, created, isDefault, lastTransactionAt
    case cachedBalance = "currentBalance"
  }

  // MARK: - Initializer for creating new accounts
  init(
    name: String,
    type: AccountType,
    openingBalance: Double,
    cachedBalance: Double? = nil,
    currency: String = "PKR",
    sourceId: String? = nil,
    isArchived: Bool = false,
    created: Date? = nil,
    isDefault: Bool = false,
    lastTransactionAt: Date? = nil
  ) {
    self.name              = name
    self.type              = type.rawValue
    self.openingBalance    = openingBalance
    self.cachedBalance     = cachedBalance ?? openingBalance
    self.currency          = currency
    self.userId            = AppData.user?.id ?? ""
    self.sourceId          = sourceId
    self.isArchived        = isArchived
    self.created           = created
    self.isDefault         = isDefault
    self.lastTransactionAt = lastTransactionAt
  }

  // MARK: - Data Transfer Object Mapping
  func convertToDto() -> AccountDto {
    AccountDto(
      id: id,
      name: name,
      type: AccountType.fromFirestore(type),
      openingBalance: openingBalance,
      currentBalance: cachedBalance,
      currency: currency,
      sourceId: sourceId,
      isArchived: isArchived,
      createdAt: created,
      isDefault: isDefault
    )
  }

  // MARK: - Equatable & Hashable Conformance
  public static func == (lhs: Account, rhs: Account) -> Bool { lhs.id == rhs.id }
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Account {
  func computedBalance(from transactions: [AccountTransaction]) -> Double {
    transactions
      .filter { $0.accountId == self.id }
      .reduce(openingBalance) { $0 + $1.amount }
  }
}

//
// MARK: - Income Source Domain Model
//
class IncomeSource: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let name: String
  let created: Date?

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.userId = try container.decode(String.self, forKey: .userId)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.created = try container.decodeIfPresent(Date.self, forKey: .created)
  }

  init(name: String, created: Date? = nil) {
    self.name = name
    self.userId = AppData.user?.id ?? ""
    self.created = created
  }

  func convertToDto() -> IncomeSourceDto {
    return IncomeSourceDto(
      id: self.id,
      name: self.name,
      icon: IncomeSource.getAutoIcon(forName: self.name),
      createdAt: created
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
