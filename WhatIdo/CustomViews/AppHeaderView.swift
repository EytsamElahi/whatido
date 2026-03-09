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
    var secondTrailingButtonIcon: String? = nil
    var backAction: () -> Void
    var trailingButtonAction: (() -> Void)? = nil
    var secondTrailingButtonAction: (() -> Void)? = nil
    var isBackButton: Bool = true

    var body: some View {
        HStack {
            Button(action: backAction) {
                if isBackButton {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 38, height: 38)

                        Text(AppData.user?.name?.prefix(1).uppercased() ?? "U")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(Color.appPrimaryColor)
                    }
                }
            }

            Text(title)
                .font(.customFont(family: .quicksand, name: .bold, size: .x30))
                .foregroundStyle(Color.textPrimary)
                .padding(.leading, 8)

            Spacer()

            if let secondIcon = secondTrailingButtonIcon {
                Button(action: { secondTrailingButtonAction?() }) {
                    headerIconCircle(systemName: secondIcon)
                }
            }

            if let icon = trailingButtonIcon {
                Button(action: { trailingButtonAction?() }) {
                    headerIconCircle(systemName: icon)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 15)
    }

    @ViewBuilder
    private func headerIconCircle(systemName: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 45, height: 45)
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundStyle(Color.appPrimaryColor)
        }
    }
}
