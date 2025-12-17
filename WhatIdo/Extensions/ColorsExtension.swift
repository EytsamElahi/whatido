//
//  ColorsExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/05/2025.
//

import SwiftUI

import SwiftUI

extension Color {
    // 1. Accent stays same (Teal pops beautifully on black)
    static let appPrimaryColor = Color(hex: "00C7BE")
    
    // 2. Main Background -> Pure Black (OLED Friendly)
    static let appBackground = Color.black
    
    // 3. Cards -> Dark Charcoal (Apple's standard Dark Mode gray)
    static let cardBackground = Color(hex: "1C1C1E")
    
    // 4. Text Colors (Explicitly define for dark mode)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8E93") // Light Gray
    
    // Helper to use Hex
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
