//
//  OnboardingPageView.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import SwiftUI

struct OnboardingPageView: View {
  let page: OnboardingPage
  @State private var isAnimating = false

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      // Visual section
      visualSection
        .scaleEffect(isAnimating ? 1 : 0.8)
        .opacity(isAnimating ? 1 : 0)

      Spacer()
        .frame(height: 50)

      // Text content
      textContent
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)

      // Feature highlights for specific pages
      if page.id > 0 && page.id < 5 {
        featureHighlights
          .opacity(isAnimating ? 1 : 0)
          .offset(y: isAnimating ? 0 : 20)
      }

      Spacer()
      Spacer()
    }
    .padding(.horizontal, 24)
    .onAppear {
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
        isAnimating = true
      }
    }
    .onChange(of: page.id) { _ in
      isAnimating = false
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
        isAnimating = true
      }
    }
  }

  private var visualSection: some View {
    ZStack {
      // Outer glow ring
      Circle()
        .stroke(
          LinearGradient(
            colors: [Color.appPrimaryColor.opacity(0.4), Color.appPrimaryColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 2
        )
        .frame(width: 200, height: 200)

      // Middle ring
      Circle()
        .fill(Color.appPrimaryColor.opacity(0.08))
        .frame(width: 180, height: 180)

      // Inner circle with icon
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [Color.appPrimaryColor.opacity(0.25), Color.appPrimaryColor.opacity(0.1)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 140, height: 140)

        Image(systemName: page.iconName)
          .font(.system(size: 56, weight: .medium))
          .foregroundStyle(
            LinearGradient(
              colors: [Color.appPrimaryColor, Color.appPrimaryColor.opacity(0.8)],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      }

      // Floating accent dots
      floatingDots
    }
  }

  private var floatingDots: some View {
    ZStack {
      Circle()
        .fill(Color.appPrimaryColor.opacity(0.6))
        .frame(width: 8, height: 8)
        .offset(x: -90, y: -60)

      Circle()
        .fill(Color.appPrimaryColor.opacity(0.4))
        .frame(width: 6, height: 6)
        .offset(x: 85, y: -40)

      Circle()
        .fill(Color.appPrimaryColor.opacity(0.5))
        .frame(width: 10, height: 10)
        .offset(x: 70, y: 70)

      Circle()
        .fill(Color.appPrimaryColor.opacity(0.3))
        .frame(width: 5, height: 5)
        .offset(x: -80, y: 50)
    }
  }

  private var textContent: some View {
    VStack(spacing: 16) {
      Text(page.title)
        .font(.customFont(family: .quicksand, name: .bold, size: .x28))
        .foregroundStyle(Color.textPrimary)
        .multilineTextAlignment(.center)

      Text(page.subtitle)
        .font(.customFont(family: .quicksand, name: .medium, size: .x16))
        .foregroundStyle(Color.textSecondary)
        .multilineTextAlignment(.center)
        .lineSpacing(6)
        .fixedSize(horizontal: false, vertical: true)

      // Tagline - only on "Track Every Expense" screen (index 1)
      if page.id == 1 {
        Text("What gets tracked, gets managed.")
          .font(.system(size: 12, weight: .medium, design: .monospaced))
          .foregroundStyle(Color.textSecondary.opacity(0.6))
          .padding(.top, 4)
      }
    }
  }

  private var featureHighlights: some View {
    HStack(spacing: 16) {
      ForEach(getFeatureItems(), id: \.0) { item in
        featureChip(icon: item.0, text: item.1)
      }
    }
    .padding(.top, 30)
  }

  private func featureChip(icon: String, text: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Color.appPrimaryColor)

      Text(text)
        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
        .foregroundStyle(Color.textSecondary)
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 10)
    .background(
      Capsule()
        .fill(Color.white.opacity(0.06))
        .overlay(
          Capsule()
            .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    )
  }

  private func getFeatureItems() -> [(String, String)] {
    switch page.id {
    case 1:
      return [("bolt.fill", "Quick Add"), ("tag.fill", "Categories")]
    case 2:
      return [("folder.fill", "Projects"), ("chart.bar.fill", "Track")]
    case 3:
      return [("indianrupeesign.circle.fill", "Budgets"), ("chart.pie.fill", "Analytics")]
    case 4:
      return [("globe", "7 Currencies"), ("arrow.triangle.2.circlepath", "Live Rates")]
    default:
      return []
    }
  }
}

#Preview {
  ZStack {
    Color.appBackground.ignoresSafeArea()
    OnboardingPageView(page: OnboardingPage.pages[1])
  }
}
