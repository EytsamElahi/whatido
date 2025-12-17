//
//  AppHeaderView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI

struct AppHeaderView: View {
    var title: String
    var backAction: () -> Void
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

            // Optional: Profile Icon or Empty
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 15)
    }
}
