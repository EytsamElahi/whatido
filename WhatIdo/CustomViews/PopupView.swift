//
//  PopupView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//


// Views/Components/PopupView.swift
import SwiftUI

struct PopupView: View {
    let popup: Popup
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Icon
            Image(systemName: popup.style.icon)
                .font(.system(size: 50))
                .foregroundStyle(popup.style.color)
                .padding(.top, 10)
            
            // 2. Text Content
            VStack(spacing: 8) {
                Text(popup.title)
                    .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                    .foregroundStyle(.white)
                
                Text(popup.message)
                    .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                    .foregroundStyle(Color.gray) // Ya tumhara .textSecondary
                    .multilineTextAlignment(.center)
            }
            
            // 3. Buttons
            HStack(spacing: 15) {
                // Secondary Button (Cancel) - Left Side
                if let secondary = popup.secondaryAction {
                    Button {
                        secondary.action()
                        OverlayManager.shared.dismissPopup()
                    } label: {
                        Text(secondary.title)
                            .font(.customFont(family: .inter, name: .semiBold, size: .x14))
                            .foregroundStyle(Color.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                
                // Primary Button (OK / Delete) - Right Side
                if let primary = popup.primaryAction {
                    Button {
                        primary.action()
                        OverlayManager.shared.dismissPopup()
                    } label: {
                        Text(primary.title)
                            .font(.customFont(family: .inter, name: .bold, size: .x14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                primary.role == .destructive ? Color.red : Color.appPrimaryColor
                            )
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(Color.cardBackground) // Tumhara card color
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 30) // Side margins
    }
}