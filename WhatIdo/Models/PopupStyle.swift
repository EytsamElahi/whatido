//
//  PopupStyle.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//


// Models/Popup.swift
import SwiftUI

// 1. Style define karo (Icon aur Color ke liye)
enum PopupStyle {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

// 2. Action Button Model (e.g., "Yes", "Cancel")
struct PopupAction: Identifiable {
    let id = UUID()
    let title: String
    let role: ButtonRole? // destructive (red) or cancel (blue)
    let action: () -> Void
}

// 3. Main Popup Model
struct Popup: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let style: PopupStyle
    let primaryAction: PopupAction?   // Main button (e.g., "Delete", "OK")
    let secondaryAction: PopupAction? // Optional (e.g., "Cancel")

    // 🔥 2. Manual Equality Check (Magic Fix)
        static func == (lhs: Popup, rhs: Popup) -> Bool {
            // Sirf ID match karo. Agar ID same hai, to popup same hai.
            return lhs.id == rhs.id
        }
}

