//
//  AccountType.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//


enum AccountType: String, Codable, CaseIterable, Identifiable {
    case bank = "Bank Account"
    case digitalWallet = "Digital Wallet"
    case cash = "Cash"
    case investment = "Investment"
    
    var id: String { rawValue }
}