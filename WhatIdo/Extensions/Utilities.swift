//
//  Utilities.swift
//  WhatIdo
//
//  Created by eytsam elahi on 26/05/2025.
//

import Foundation

class Utilities {
    static func dateFrom(monthName: String, year: Int) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "en_US") // or use Locale.current for user's locale

        // Convert month name to month number
        guard let monthDate = formatter.date(from: monthName) else { return nil }
        let calendar = Calendar.current
        let month = calendar.component(.month, from: monthDate)

        // Create date from year and month
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1 // default to first of month

        return calendar.date(from: components)
    }
}
