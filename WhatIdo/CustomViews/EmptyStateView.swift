//
//  EmptyStateView.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import SwiftUI

struct EmptyStateView: View {
  let icon: String
  let title: String
  let subtitle: String
  var buttonTitle: String? = nil
  var buttonAction: (() -> Void)? = nil

  @State private var isAnimating = false

  var body: some View {
    VStack(spacing: 20) {
      // Icon with glow
      ZStack {
        Circle()
          .fill(Color.appPrimaryColor.opacity(0.1))
          .frame(width: 100, height: 100)

        Image(systemName: icon)
          .font(.system(size: 40, weight: .medium))
          .foregroundStyle(Color.appPrimaryColor.opacity(0.8))
      }
      .scaleEffect(isAnimating ? 1 : 0.8)
      .opacity(isAnimating ? 1 : 0)

      // Text content
      VStack(spacing: 10) {
        Text(title)
          .font(.customFont(family: .quicksand, name: .bold, size: .x20))
          .foregroundStyle(Color.textPrimary)

        Text(subtitle)
          .font(.customFont(family: .quicksand, name: .medium, size: .x14))
          .foregroundStyle(Color.textSecondary)
          .multilineTextAlignment(.center)
          .lineSpacing(4)
      }
      .opacity(isAnimating ? 1 : 0)
      .offset(y: isAnimating ? 0 : 10)

      // Optional action button
      if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
        Button {
          buttonAction()
        } label: {
          HStack(spacing: 8) {
            Text(buttonTitle)
              .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))

            Image(systemName: "arrow.right")
              .font(.system(size: 14, weight: .semibold))
          }
          .foregroundStyle(Color.appPrimaryColor)
          .padding(.horizontal, 24)
          .padding(.vertical, 14)
          .background(
            Capsule()
              .fill(Color.appPrimaryColor.opacity(0.15))
          )
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 10)
        .padding(.top, 10)
      }
    }
    .padding(.horizontal, 40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        isAnimating = true
      }
    }
  }
}

#Preview {
  ZStack {
    Color.appBackground.ignoresSafeArea()
    EmptyStateView(
      icon: "dollarsign.circle",
      title: "No Expenses Yet",
      subtitle: "Tap '+ Add New' to record your first expense",
      buttonTitle: "Add Expense",
      buttonAction: {}
    )
  }
}
