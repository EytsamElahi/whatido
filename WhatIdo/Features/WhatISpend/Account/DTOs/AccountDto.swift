//
//  AccountDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import Foundation

struct AccountDto: Hashable, AppDataType {
    let id: String
    let name: String
    let type: AccountType
    let currentBalance: Double
    let currency: String
    let sourceId: String
    var sourceName: String = ""
}
