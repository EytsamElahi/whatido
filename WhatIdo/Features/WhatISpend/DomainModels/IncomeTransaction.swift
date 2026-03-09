//
//  IncomeTransaction.swift
//  WhatIdo
//

import Foundation

class IncomeTransaction: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let accountId: String
  let sourceId: String
  let sourceName: String    // snapshot — preserved if source is deleted
  let amount: Double
  let currency: String
  let note: String?
  let receivedAt: Date
  let createdAt: Date
  let metadata: [String: String]?

  required init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.id         = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
    self.userId     = try c.decode(String.self, forKey: .userId)
    self.accountId  = try c.decode(String.self, forKey: .accountId)
    self.sourceId   = try c.decode(String.self, forKey: .sourceId)
    self.sourceName = try c.decode(String.self, forKey: .sourceName)
    self.amount     = try c.decode(Double.self, forKey: .amount)
    self.currency   = try c.decode(String.self, forKey: .currency)
    self.note       = try c.decodeIfPresent(String.self, forKey: .note)
    self.receivedAt = try c.decodeIfPresent(Date.self, forKey: .receivedAt) ?? Date()
    self.createdAt  = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    self.metadata   = try c.decodeIfPresent([String: String].self, forKey: .metadata)
  }

  init(
    accountId: String,
    sourceId: String,
    sourceName: String,
    amount: Double,
    currency: String,
    note: String? = nil,
    receivedAt: Date = Date(),
    metadata: [String: String]? = nil
  ) {
    self.userId     = AppData.user?.id ?? ""
    self.accountId  = accountId
    self.sourceId   = sourceId
    self.sourceName = sourceName
    self.amount     = amount
    self.currency   = currency
    self.note       = note
    self.receivedAt = receivedAt
    self.createdAt  = Date()
    self.metadata   = metadata
  }

  public static func == (lhs: IncomeTransaction, rhs: IncomeTransaction) -> Bool { lhs.id == rhs.id }
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }

  func convertToDto(accountName: String) -> IncomeTransactionDto {
    IncomeTransactionDto(
      id: id,
      accountId: accountId,
      accountName: accountName,
      sourceId: sourceId,
      sourceName: sourceName,
      amount: amount,
      currency: currency,
      note: note,
      receivedAt: receivedAt
    )
  }
}
