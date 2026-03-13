//
//  AccountTransfer.swift
//  WhatIdo
//

import Foundation

class AccountTransfer: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let fromAccountId: String
  let fromAccountName: String  // snapshot
  let toAccountId: String
  let toAccountName: String    // snapshot
  let toAccountIsLiability: Bool
  let amount: Double
  let fee: Double?
  let currency: String
  let note: String?
  let transferredAt: Date
  let createdAt: Date

  required init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.id                   = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
    self.userId               = try c.decode(String.self, forKey: .userId)
    self.fromAccountId        = try c.decode(String.self, forKey: .fromAccountId)
    self.fromAccountName      = try c.decode(String.self, forKey: .fromAccountName)
    self.toAccountId          = try c.decode(String.self, forKey: .toAccountId)
    self.toAccountName        = try c.decode(String.self, forKey: .toAccountName)
    self.toAccountIsLiability = try c.decodeIfPresent(Bool.self, forKey: .toAccountIsLiability) ?? false
    self.amount               = try c.decode(Double.self, forKey: .amount)
    self.fee                  = try c.decodeIfPresent(Double.self, forKey: .fee)
    self.currency             = try c.decode(String.self, forKey: .currency)
    self.note                 = try c.decodeIfPresent(String.self, forKey: .note)
    self.transferredAt        = try c.decodeIfPresent(Date.self, forKey: .transferredAt) ?? Date()
    self.createdAt            = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
  }

  init(
    fromAccountId: String,
    fromAccountName: String,
    toAccountId: String,
    toAccountName: String,
    toAccountIsLiability: Bool = false,
    amount: Double,
    fee: Double? = nil,
    currency: String,
    note: String? = nil,
    transferredAt: Date = Date()
  ) {
    self.userId               = AppData.user?.id ?? ""
    self.fromAccountId        = fromAccountId
    self.fromAccountName      = fromAccountName
    self.toAccountId          = toAccountId
    self.toAccountName        = toAccountName
    self.toAccountIsLiability = toAccountIsLiability
    self.amount               = amount
    self.fee                  = fee
    self.currency             = currency
    self.note                 = note
    self.transferredAt        = transferredAt
    self.createdAt            = Date()
  }

  public static func == (lhs: AccountTransfer, rhs: AccountTransfer) -> Bool { lhs.id == rhs.id }
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
