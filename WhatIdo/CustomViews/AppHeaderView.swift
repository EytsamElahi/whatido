//
//  AppHeaderView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI

struct AppHeaderView: View {
    var title: String
    var trailingButtonIcon: String? = nil
    var backAction: () -> Void
    var trailingButtonAction: (() -> Void)? = nil
    var body: some View {
        HStack {
            Button(action: {
                backAction()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
            }

            Text(title)
                .font(.customFont(family: .quicksand, name: .bold, size: .x30))
                .foregroundStyle(Color.textPrimary)
                .padding(.leading, 8)

            Spacer()
            if let icon = trailingButtonIcon {
                Button(action: {
                    trailingButtonAction?()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 45, height: 45)

                        Image(systemName: icon) // 📂
                            .font(.system(size: 20))
                            .foregroundStyle(Color.appPrimaryColor) // Teal Icon
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 15)
    }
}
