//
//  IncomeTransactionDto.swift
//  WhatIdo
//

import Foundation

struct IncomeTransactionDto: Identifiable, Hashable {
  let id: String
  let accountId: String
  let accountName: String
  let sourceId: String
  let sourceName: String
  let amount: Double
  let currency: String
  let note: String?
  let receivedAt: Date
}
