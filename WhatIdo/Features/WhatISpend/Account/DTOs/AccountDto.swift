//
//  AccountDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import Foundation

/// Data Transfer Object for Account model
/// Used for UI mapping and passing data between layers
struct AccountDto: Hashable, AppDataType {
    let id: String
    let name: String
    let type: AccountType
    let openingBalance: Double
    let currentBalance: Double
    let currency: String
    let sourceId: String?
    var sourceName: String = ""
    let isArchived: Bool
    let createdAt: Date?
}
