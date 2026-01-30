//
//  OnboardingView.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import SwiftUI

struct OnboardingView: View {
  @StateObject var viewModel: OnboardingViewModel
  @EnvironmentObject var navigation: NavigationManager
  @State private var isAnimating = false

  var body: some View {
    ZStack {
      Color.appBackground.ignoresSafeArea()

      // Ambient glow effect
      Circle()
        .fill(Color.appPrimaryColor)
        .frame(width: 300, height: 300)
        .blur(radius: 120)
        .offset(y: -200)
        .opacity(0.35)

      VStack(spacing: 0) {
        // Top bar with skip button
        topBar
          .opacity(isAnimating ? 1 : 0)

        // Page content
        TabView(selection: $viewModel.currentPage) {
          ForEach(viewModel.pages) { page in
            OnboardingPageView(page: page)
              .tag(page.id)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.4), value: viewModel.currentPage)

        // Bottom section
        bottomSection
          .opacity(isAnimating ? 1 : 0)
          .offset(y: isAnimating ? 0 : 30)
      }
    }
    .navigationBarBackButtonHidden()
    .onAppear {
      withAnimation(.easeOut(duration: 0.8)) {
        isAnimating = true
      }
    }
    .onChange(of: viewModel.isOnboardingComplete) { completed in
      if completed {
        navigation.push(screen: .login)
      }
    }
  }

  private var topBar: some View {
    HStack {
      // Progress text for non-welcome screens
      if let progressText = viewModel.currentPageData.progressText {
        Text(progressText)
          .font(.customFont(family: .quicksand, name: .semiBold, size: .x14))
          .foregroundStyle(Color.textSecondary)
      }

      Spacer()

      if !viewModel.isLastPage {
        Button {
          viewModel.skipOnboarding()
        } label: {
          Text("Skip")
            .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
            .foregroundStyle(Color.textSecondary)
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 16)
    .frame(height: 50)
  }

  private var bottomSection: some View {
    VStack(spacing: 28) {
      // Progress dots
      progressIndicator

      // Premium glass button
      Button {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
          if viewModel.isLastPage {
            viewModel.completeOnboarding()
          } else {
            viewModel.nextPage()
          }
        }
      } label: {
        ZStack {
          // Glass background
          RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(
                  LinearGradient(
                    colors: [
                      Color.appPrimaryColor.opacity(0.8),
                      Color.appPrimaryColor.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: 1.5
                )
            )

          HStack(spacing: 10) {
            Text(buttonTitle)
              .font(.customFont(name: .bold, size: .x18))
              .foregroundStyle(
                LinearGradient(
                  colors: [Color.white, Color.white.opacity(0.9)],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )

            Image(systemName: viewModel.isLastPage ? "checkmark" : "arrow.right")
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(Color.appPrimaryColor)
          }
        }
        .frame(height: 58)
      }
      .padding(.horizontal, 24)
    }
    .padding(.bottom, 50)
  }

  private var buttonTitle: String {
    if viewModel.isFirstPage {
      return "Get Started"
    } else if viewModel.isLastPage {
      return "Start Tracking"
    } else {
      return "Continue"
    }
  }

  private var progressIndicator: some View {
    HStack(spacing: 8) {
      ForEach(viewModel.pages) { page in
        Capsule()
          .fill(
            page.id == viewModel.currentPage
            ? Color.appPrimaryColor
            : Color.white.opacity(0.15)
          )
          .frame(width: page.id == viewModel.currentPage ? 28 : 8, height: 8)
          .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentPage)
      }
    }
  }
}

#Preview {
  OnboardingView(viewModel: OnboardingViewModel())
    .environmentObject(NavigationManager())
}
