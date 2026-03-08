//
//  DoubleExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//

import Foundation

extension Double {

    var toCurrency: String {
        return formatCurrency(with: nil)
    }

    func formatCurrency(with code: String?) -> String {
        let manager = CurrencyManager.shared
        let fallback = CurrencyOption(code: "USD", locale: "en_US", symbol: "$")
        let currencyOption = manager.getCurrencyOption(for: code) ?? manager.activeCurrency ?? fallback

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyOption.code
        formatter.locale = Locale(identifier: currencyOption.locale)

        // Agar currency PKR/INR hai to decimals hata dete hain (Clean lagta hai)
        if ["PKR", "INR", "JPY"].contains(currencyOption.code) {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: self)) ?? "\(currencyOption.code) \(self)"
    }

    /// Formats the amount with proper decimal precision based on currency, without the currency symbol.
    /// Uses NumberFormatter for locale-aware number formatting (grouping separators, etc.)
    func formattedAmount(for currencyCode: String? = nil) -> String {
        let manager = CurrencyManager.shared
        let fallback = CurrencyOption(code: "USD", locale: "en_US", symbol: "$")
        let currencyOption = manager.getCurrencyOption(for: currencyCode) ?? manager.activeCurrency ?? fallback

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: currencyOption.locale)

        // Currency-specific precision: no decimals for PKR/INR/JPY, 2 decimals for others
        if ["PKR", "INR", "JPY"].contains(currencyOption.code) {
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self)
    }
}
