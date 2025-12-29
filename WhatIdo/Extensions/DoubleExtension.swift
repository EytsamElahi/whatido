//
//  DoubleExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//

import Foundation

extension Double {

    var toCurrency: String {
        let manager = CurrencyManager.shared

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = manager.currencyCode
        formatter.locale = Locale(identifier: manager.localeIdentifier ?? "")

        // Agar currency PKR/INR hai to decimals hata dete hain (Clean lagta hai)
        if ["PKR", "INR", "JPY"].contains(manager.currencyCode) {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: self)) ?? "\(manager.currencyCode) \(self)"
    }
}
