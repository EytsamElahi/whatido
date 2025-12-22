//
//  ToastStyle.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//

import SwiftUI

enum ToastStyle {
    case error
    case success
    case info
    
    var color: Color {
        switch self {
        case .error: return Color.red
        case .success: return Color.green
        case .info: return Color.blue
        }
    }
    
    var icon: String {
        switch self {
        case .error: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3.0
}
