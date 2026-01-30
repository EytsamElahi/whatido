//
//  SignInSheetView.swift
//  WhatIdo
//
//  Created by Claude on 30/01/2026.
//

import SwiftUI

struct SignInSheetView: View {
  @ObservedObject var authViewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.cardBackground.ignoresSafeArea()

      VStack(spacing: 24) {
        // Handle bar
        Capsule()
          .fill(Color.white.opacity(0.3))
          .frame(width: 40, height: 5)
          .padding(.top, 12)

        // Header
        VStack(spacing: 8) {
          Text("Get Started")
            .font(.customFont(family: .quicksand, name: .bold, size: .x24))
            .foregroundStyle(.white)

          Text("Sign in to sync your data across devices")
            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 8)

        // Sign-in buttons
        VStack(spacing: 14) {
          SocialButtonView(
            image: .google,
            title: "Continue with Google",
            backgroundColor: .googleBackground,
            fontColor: .black,
            imageWidth: 20,
            imageHeight: 20,
            cornerRadius: 14,
            height: 52
          ) {
            authViewModel.authenticate(.google)
          }

          SocialButtonView(
            image: .apple,
            title: "Continue with Apple",
            backgroundColor: Color.white.opacity(0.1),
            fontColor: .white,
            imageWidth: 18,
            imageHeight: 22,
            cornerRadius: 14,
            height: 52
          ) {
            authViewModel.authenticate(.apple)
          }
        }
        .padding(.horizontal, 4)

        // Terms
        Text("By continuing, you agree to our [Terms & Privacy Policy](https://fire-cord-c32.notion.site/Yaru-Legal-Support-2ec64ce7ca4c80b595fbcba6ce8c5152).")
          .font(.caption2)
          .foregroundStyle(.gray.opacity(0.6))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 20)
          .padding(.bottom, 10)
      }
      .padding(.horizontal, 20)
    }
    .sheet(isPresented: $authViewModel.showUsernameSheet) {
      UsernameView()
        .environmentObject(authViewModel)
        .presentationDetents([.height(300)])
    }
    .interactiveDismissDisabled()
  }
}

#Preview {
  SignInSheetView(authViewModel: AuthenticationViewModel(authService: FirebaseAuthService()))
}
