//
//  CapsuleView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import SwiftUI

struct CapsuleView: View {
    var icon: String? = nil
    var name: String
    var isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(name)
        }
        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
        .foregroundStyle(isSelected ? Color.black : Color.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color.appPrimaryColor : Color.white.opacity(0.1))
        )
    }
}
