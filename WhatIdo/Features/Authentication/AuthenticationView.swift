//
//  AuthenticationView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var navManager: NavigationManager
    let appPrimary = Color.appPrimaryColor

    @State private var isAnimating = false
    var body: some View {
        ZStack {
            // 1. BACKGROUND
            Color.appBackground.ignoresSafeArea()

            // 2. AMBIENT GLOW (Yellow Effect peeche)
            Circle()
                .fill(appPrimary)
                .frame(width: 250, height: 250)
                .blur(radius: 100) // Neon Glow effect
                .offset(y: -150)
                .opacity(0.4)

            VStack(spacing: 40) {
                Spacer()

                // 3. LOGO & BRANDING
                VStack(spacing: 15) {
                    Image(.splashIcon) // Yahan apna Logo lagana
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(appPrimary)
                        //.shadow(color: appPrimary.opacity(0.8), radius: 20, x: 0, y: 0)

                    Text("Yaru")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    VStack(spacing: 5) {
                        Text("Track your spending")
                            .font(.body)
                            .foregroundStyle(.white)
                            .tracking(2) // Letter spacing
                        Text("What gets measured, gets managed.")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(.gray)

                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)

                Spacer()

                // 4. BUTTONS SECTION
                VStack(spacing: 16) {
                    SocialButtonView(image: .google, title: "Continue with Google", backgroundColor: .googleBackground, fontColor: .black, imageWidth: 20, imageHeight: 20, action: {
                        viewModel.authenticate(.google)
                    }).padding(.horizontal)
                    SocialButtonView(image: .apple, title: "Continue with Apple", backgroundColor: .cardBackground, fontColor: .white,imageWidth: 18, imageHeight: 22, action: {
                        viewModel.authenticate(.apple)
                    }).padding(.horizontal)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)

                // 5. FOOTER (Terms)
                Text("By continuing, you agree to our [Terms & Privacy Policy](https://fire-cord-c32.notion.site/Yaru-Legal-Support-2ec64ce7ca4c80b595fbcba6ce8c5152).")
                    .font(.caption2)
                    .foregroundStyle(.gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }.navigationBarBackButtonHidden()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }.onChange(of: viewModel.navigateToCurrency) {
            navManager.push(screen: .currencySettings(false))
        }
        .onChange(of: viewModel.navigateToDashboard) {
            navManager.push(screen: .spendings)
        }
        .sheet(isPresented: $viewModel.showUsernameSheet) {
            UsernameView()
                .environmentObject(viewModel)
                .presentationDetents([.height(300)])
        }.interactiveDismissDisabled()
    }
}


#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel(authService: FirebaseAuthService()))
}
