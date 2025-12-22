//
//  ToastView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//

import SwiftUI

struct ToastView: View {
    let toast: Toast
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: toast.style.icon)
                .foregroundColor(toast.style.color)
                .font(.system(size: 20))
            
            Text(toast.message)
                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "1C1C1E")) // Ya Color.cardBackground agar tumhara custom color hai
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(toast.style.color.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}
