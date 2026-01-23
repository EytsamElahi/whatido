//
//  ExchangeRatesModel.swift
//  WhatIdo
//
//  Created by Antigravity on 2026-01-23.
//

import Foundation

struct ExchangeRatesModel: Codable {
    let base_code: String
    let time_last_update_unix: TimeInterval
    let conversion_rates: [String: Double]
    
    // Helper to check if expired (> 24 hours)
    var isExpired: Bool {
        let now = Date().timeIntervalSince1970
        return (now - time_last_update_unix) > 86400 // 24 hours in seconds
    }
}
