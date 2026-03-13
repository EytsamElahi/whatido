//
//  AccountType.swift
//  WhatIdo
//

enum AccountType: String, Codable, CaseIterable, Identifiable {
  // Assets
  case bank          = "bank"
  case digitalWallet = "digitalWallet"
  case cash          = "cash"
  case investment    = "investment"
  case savings       = "savings"

  // Liabilities
  case creditCard    = "creditCard"
  case loan          = "loan"

  var id: String { rawValue }

  var isLiability: Bool {
    switch self {
    case .creditCard, .loan: return true
    default: return false
    }
  }

  var displayName: String {
    switch self {
    case .bank:          return "Bank"
    case .digitalWallet: return "Digital Wallet"
    case .cash:          return "Cash"
    case .investment:    return "Investment"
    case .savings:       return "Savings"
    case .creditCard:    return "Credit Card"
    case .loan:          return "Loan"
    }
  }

  var icon: String {
    switch self {
    case .bank:          return "building.columns"
    case .digitalWallet: return "wallet.pass"
    case .cash:          return "banknote"
    case .investment:    return "chart.line.uptrend.xyaxis"
    case .savings:       return "piggybank"
    case .creditCard:    return "creditcard"
    case .loan:          return "doc.text"
    }
  }

  /// Handles old Firestore raw values like "Bank Account", "Digital Wallet", etc.
  static func fromFirestore(_ raw: String) -> AccountType {
    if let direct = AccountType(rawValue: raw) { return direct }
    switch raw {
    case "Bank Account":    return .bank
    case "Digital Wallet":  return .digitalWallet
    case "Cash":            return .cash
    case "Investment":      return .investment
    default:                return .cash
    }
  }
}
