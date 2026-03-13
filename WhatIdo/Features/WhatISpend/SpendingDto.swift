//
//  SpendingDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 15/05/2025.
//

import Foundation
import SwiftUI

struct SpendingDto: Hashable, Identifiable, AppDataType {
  let id: String
  let name: String
  let amount: Double
  let date: Date
  let type: String
  let created: Date
  let spendingTypeId: Int
  let spendingCategoryId: Int
  let isArchived: Bool
  let project: SpendingProjectDto?
  var account: SpendingAccountDto?
  let currencyCode: String?

}

struct SpendingProjectDto: Hashable, AppDataType {
  let id: String?
  let projectName: String?
  let projectIcon: String?
}
struct SpendingAccountDto: Hashable, Codable {
  let id: String
  let name: String
  var isLiability: Bool = false
}

extension SpendingDto {

  var icon: String {
    // IDs match karein (User ke naye JSON ke mutabiq)
    switch spendingTypeId {

    // HOUSING (1: Rent, 2: Utility, 18: Maintenance)
    case 1, 18: return "house.fill"
    case 2: return "bolt.fill"

    // TRANSPORT (3: Fuel, 4: Public Transit)
    case 3: return "fuelpump.fill"
    case 4: return "car.fill"

    // FOOD (5: Groceries, 6: Dining Out)
    case 5: return "cart.fill"
    case 6: return "fork.knife"

    // HEALTH (7: Doctor, 19: Pharmacy)
    case 7: return "stethoscope"
    case 19: return "pills.fill"

    // DEBT & FINANCE (9: Loan, 10: Emergency Fund)
    case 9: return "banknote.fill"
    case 10: return "lock.shield.fill"

    // ENTERTAINMENT (11: Subs, 20: Movies)
    case 11: return "repeat.circle.fill"
    case 20: return "popcorn.fill"

    // EDUCATION (13: Courses)
    case 13: return "book.closed.fill"

    // PERSONAL CARE (16: Salon, 21: Clothing)
    case 16: return "scissors"
    case 21: return "tshirt.fill"

    // SHOPPING (17: Electronics, 22: Household)
    case 17: return "laptopcomputer"
    case 22: return "lamp.floor.fill"

    // GIVING (23: Gifts, 24: Family)
    case 23: return "gift.fill"
    case 24: return "figure.2.and.child.holdinghands"

    default: return "tag.fill"
    }
  }

  var iconColor: Color {
    switch type.lowercased() {

    // HOUSING (Blue/Cyan)
    case "rent", "housing": return Color.blue
    case "utility bill", "utility bills", "bills", "electricity", "maintenance": return Color.cyan

    // TRANSPORT (Yellow/Orange)
    case "fuel", "petrol", "gas": return Color.yellow
    case "travel", "public transit / taxi", "transport", "uber", "taxi": return Color.orange

    // FOOD (Green/Mint)
    case "groceries", "grocery": return Color.green
    case "dining out", "food", "dining", "restaurants": return Color.mint

    // HEALTH (Red/Pink)
    case "doctor & checkups", "health": return Color.red
    case "pharmacy / meds", "medicine": return Color.pink

    // FINANCE (Purple/Indigo)
    case "loan repayment", "debt": return Color.purple
    case "emergency fund", "savings": return Color.indigo

    // SHOPPING (Teal/Blue)
    case "shopping", "clothing & tailor", "clothes": return Color.teal
    case "electronics & gadgets": return Color.blue.opacity(0.8)
    case "household items": return Color.brown

    // PERSONAL & GIFTS (Lavender/Pink)
    case "salon & grooming", "grooming": return Color("Lavender")
    case "subscriptions", "subscription": return Color.indigo.opacity(0.8)
    case "gifts / donations", "gifts": return Color.pink.opacity(0.7)
    case "allowance", "family support": return Color.orange.opacity(0.8)

    // MISC (Dark Grey - Intentional)
    case "miscellaneous": return Color.gray

    // DEFAULT (Light Grey - Fallback)
    default: return Color.gray.opacity(0.5)
    }
  }
}
