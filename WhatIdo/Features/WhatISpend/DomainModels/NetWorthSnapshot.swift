//
//  NetWorthSnapshot.swift
//  WhatIdo
//

import Foundation

struct AccountBalanceSnapshot: Codable {
  let accountId: String
  let accountName: String
  let balance: Double
  let currency: String
  let type: AccountType
}

class NetWorthSnapshot: FirestoreIdentifiable {
  var id: String = ""
  let userId: String
  let totalAssets: Double
  let totalLiabilities: Double
  let netWorth: Double          // totalAssets - totalLiabilities
  let accountBreakdown: [AccountBalanceSnapshot]
  let recordedAt: Date

  required init(from decoder: any Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.id               = try c.decodeIfPresent(String.self, forKey: .id) ?? ""
    self.userId           = try c.decode(String.self, forKey: .userId)
    self.totalAssets      = try c.decode(Double.self, forKey: .totalAssets)
    self.totalLiabilities = try c.decode(Double.self, forKey: .totalLiabilities)
    self.netWorth         = try c.decode(Double.self, forKey: .netWorth)
    self.accountBreakdown = try c.decodeIfPresent([AccountBalanceSnapshot].self, forKey: .accountBreakdown) ?? []
    self.recordedAt       = try c.decodeIfPresent(Date.self, forKey: .recordedAt) ?? Date()
  }

  init(
    totalAssets: Double,
    totalLiabilities: Double,
    accountBreakdown: [AccountBalanceSnapshot],
    recordedAt: Date = Date()
  ) {
    self.userId           = AppData.user?.id ?? ""
    self.totalAssets      = totalAssets
    self.totalLiabilities = totalLiabilities
    self.netWorth         = totalAssets - totalLiabilities
    self.accountBreakdown = accountBreakdown
    self.recordedAt       = recordedAt
  }

  public static func == (lhs: NetWorthSnapshot, rhs: NetWorthSnapshot) -> Bool { lhs.id == rhs.id }
  public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
