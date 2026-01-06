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

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }

//    init?(hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//        var rgb: UInt64 = 0
//        var r: CGFloat = 0.0
//        var g: CGFloat = 0.0
//        var b: CGFloat = 0.0
//        var a: CGFloat = 1.0
//
//        let length = hexSanitized.count
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
//
//        if length == 6 {
//            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//            b = CGFloat(rgb & 0x0000FF) / 255.0
//        } else if length == 8 {
//            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
//            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
//            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
//            a = CGFloat(rgb & 0x000000FF) / 255.0
//        } else {
//            return nil
//        }
//        self.init(red: r, green: g, blue: b, opacity: a)
//    }
}
