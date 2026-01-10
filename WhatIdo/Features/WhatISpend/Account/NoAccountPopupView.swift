//
//  NoAccountPopupView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 09/01/2026.
//

import SwiftUI

struct NoAccountPopupView: View {
    var onAddAccount: () -> Void
    var onSkip: () -> Void // User wants to add spending directly
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Icon
                ZStack {
                    Circle().fill(Color.appPrimaryColor.opacity(0.15)).frame(width: 80, height: 80)
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 40)).foregroundStyle(Color.appPrimaryColor)
                }
                
                // Content
                VStack(spacing: 10) {
                    Text("Setup Your Wallet?")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                        .foregroundStyle(.white)
                    
                    Text("Accounts help you track your net worth and balance. You can skip this, but your spending will be 'Unlinked'.")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Actions
                VStack(spacing: 15) {
                    // Option 1: Add Account
                    Button(action: onAddAccount) {
                        Text("Add Account")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimaryColor)
                            .cornerRadius(12)
                    }
                    
                    // Option 2: Skip (Direct Spending)
                    Button(action: onSkip) {
                        Text("Skip & Add Spending")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                            .foregroundStyle(.white.opacity(0.7))
                            .underline()
                    }
                }
            }
            .padding(30)
            .background(Color.cardBackground)
            .cornerRadius(24)
            .padding(.horizontal, 30)
        }
    }
}
