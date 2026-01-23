//
//  CurrencyConfig.swift
//  WhatIdo
//
//  Created by Antigravity on 2026-01-22.
//

import Foundation

struct CurrencyConfig {
    /// Source of Truth for conversion rates relative to USD (Base).
    static var rates: [String: Double] {
        return CurrencyService.shared.rates
    }
    
    /// Fallback rates used before Firestore loads or if seeding is needed.
    static let fallbackRates: [String: Double] = [
        "USD": 1.0,
        "PKR": 278.5,
        "EUR": 0.92,
        "GBP": 0.78,
        "JPY": 145.0,
        "INR": 83.5,
        "AED": 3.67
    ]
}
