//
//  SpendingDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 15/05/2025.
//

import Foundation
import SwiftUI

struct SpendingDto: Hashable, AppDataType {
    let id: String
    let name: String
    let amount: Double
    let date: Date
    let type: String
    let created: Date
    let spendingTypeId: Int
    let spendingCategoryId: Int
    let fundSource: FundSource?
}

extension SpendingDto {

    // 1. Icon Name Logic
    var icon: String {
        // Safe comparison ke liye lowercased use kar rahe hain
        switch type.lowercased() {
        case "food", "dining", "restaurants", "sweets":
            return "fork.knife"
        case "shopping", "clothes", "accessories":
            return "bag.fill"
        case "transport", "fuel", "uber", "taxi":
            return "car.fill"
        case "grocery", "groceries", "supermarket":
            return "cart.fill"
        case "health", "medicine", "doctor", "hospital":
            return "cross.case.fill"
        case "entertainment", "movies", "netflix", "games":
            return "popcorn.fill" // ya "gamecontroller.fill"
        case "bills", "utilities", "electricity", "internet":
            return "bolt.fill" // ya "wifi"
        case "education", "books", "courses":
            return "book.fill"
        case "housing", "rent":
            return "house.fill"
        case "salary", "income":
            return "banknote.fill"
        case "subscription":
             return "repeat"
        default:
            return "tag.fill" // Default icon agar koi match na ho
        }
    }

    // 2. (Optional) Icon Background Color Logic
    // Har category ka apna color ho to UI bohot pyara lagta hai
    var iconColor: Color {
        switch type.lowercased() {
        case "food": return .orange
        case "shopping": return .blue
        case "transport": return .yellow
        case "health": return .red
        case "salary": return .green
        default: return .gray.opacity(0.2) // Default grey
        }
    }
}
