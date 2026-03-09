//
//  AccountTransaction.swift
//  WhatIdo
//

import Foundation

enum AccountTransactionType: String, Codable {
  case expense    = "expense"
  case income     = "income"
  case transfer   = "transfer"
  case adjustment = "adjustment"
  case opening    = "opening"
}

class AccountTransaction: FirestoreIdentifiable {
  var id: String = ""
  let accountId: String
  let userId: String
  let amount: Double          // positive = credit, negative = debit
  let type: AccountTransactionType
  let referenceId: String?    // spendingId, incomeTransactionId, or transferId
  let note: String?
  let createdAt: Date
  let metadata: [String: String]?

  required init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.id        = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
    self.accountId = try c.decode(String.self, forKey: .accountId)
    self.userId    = try c.decode(String.self, forKey: .userId)
    self.amount    = try c.decode(Double.self, forKey: .amount)
    self.type      = try c.decode(AccountTransactionType.self, forKey: .type)
    self.referenceId = try c.decodeIfPresent(String.self, forKey: .referenceId)
    self.note        = try c.decodeIfPresent(String.self, forKey: .note)
    self.createdAt   = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    self.metadata    = try c.decodeIfPresent([String: String].self, forKey: .metadata)
  }

  init(
    accountId: String,
    amount: Double,
    type: AccountTransactionType,
    referenceId: String? = nil,
    note: String? = nil,
    createdAt: Date = Date(),
    metadata: [String: String]? = nil
  ) {
    self.accountId   = accountId
    self.userId      = AppData.user?.id ?? ""
    self.amount      = amount
    self.type        = type
    self.referenceId = referenceId
    self.note        = note
    self.createdAt   = createdAt
    self.metadata    = metadata
  }

  public static func == (lhs: AccountTransaction, rhs: AccountTransaction) -> Bool { lhs.id == rhs.id }
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
