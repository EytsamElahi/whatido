//
//  CurrencyManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//


import SwiftUI

class CurrencyManager: ObservableObject {

    // Singleton Instance
    static let shared = CurrencyManager()
    @Published var activeCurrency: CurrencyOption?

    // Supported Currencies List
    let currencies: [CurrencyOption] = [
        CurrencyOption(code: "USD", locale: "en_US", symbol: "$"),
        CurrencyOption(code: "EUR", locale: "de_DE", symbol: "€"),
        CurrencyOption(code: "GBP", locale: "en_GB", symbol: "£"),
        CurrencyOption(code: "PKR", locale: "ur_PK", symbol: "Rs"),
        CurrencyOption(code: "INR", locale: "hi_IN", symbol: "₹"),
        CurrencyOption(code: "JPY", locale: "ja_JP", symbol: "¥"),
        CurrencyOption(code: "AED", locale: "ar_AE", symbol: "AED")
    ]

    // Init mein hum AppData se purani value load karenge
    private init() {
        if let saved = AppData.prefCurrency {
            self.activeCurrency = saved
        }
    }

    var currencyCode: String {
        return activeCurrency?.code ?? ""
    }

    var localeIdentifier: String {
        return activeCurrency?.locale ?? ""
    }

    var symbol: String {
        return activeCurrency?.symbol ?? ""
    }

    // Update Function
    func updateCurrency(option: CurrencyOption) {
        self.activeCurrency = option
        AppData.prefCurrency = option
    }

    func setCurrencyBySymbol(_ code: String) {
        if let option = currencies.first(where: { $0.code == code }) {
            self.activeCurrency = option
            AppData.prefCurrency = option
        }
    }

    func getCurrencyOption(for code: String?) -> CurrencyOption? {
        guard let code = code else { return nil }
        return currencies.first(where: { $0.code == code })
    }
}

struct CurrencyOption: Identifiable, Hashable, Codable {
    var id: String { code }
    let code: String
    let locale: String
    let symbol: String
}
