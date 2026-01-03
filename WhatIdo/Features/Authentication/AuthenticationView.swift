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
                    Image(systemName: "chart.bar.doc.horizontal.fill") // Yahan apna Logo lagana
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(appPrimary)
                        .shadow(color: appPrimary.opacity(0.8), radius: 20, x: 0, y: 0)

                    Text("WhatIDo")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Track. Save. Grow.")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .tracking(2) // Letter spacing
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)

                Spacer()

                // 4. BUTTONS SECTION
                VStack(spacing: 16) {
                    SocialButtonView(image: .google, title: "Continue with Google", backgroundColor: .googleBackground, fontColor: .black, imageWidth: 20, imageHeight: 20, action: {
                        viewModel.authenticate(.google)
                    }).padding(.horizontal)
                    SocialButtonView(image: .apple, title: "Continue with Apple", backgroundColor: .black, fontColor: .white,imageWidth: 18, imageHeight: 22, action: {
                        viewModel.authenticate(.apple)
                    }).padding(.horizontal)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)

                // 5. FOOTER (Terms)
                Text("By continuing, you agree to our Terms & Privacy Policy.")
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
            navManager.push(screen: .currencySettings)
        }
        .sheet(isPresented: $viewModel.showUsernameSheet) {
            UsernameView()
                .environmentObject(viewModel)
                .presentationDetents([.height(300)])
        }.interactiveDismissDisabled()
    }
}

