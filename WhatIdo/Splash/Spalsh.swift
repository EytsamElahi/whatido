//
//  Spalsh.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//


import SwiftUI

struct SplashView: View {
    @EnvironmentObject var navManager: NavigationManager
    // Inject Container
    let container: AppDependencyContainer
    @ObservedObject var overlayManager = OverlayManager.shared
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack(path: $navManager.path) {
                ZStack {
                    Color.cardBackground.ignoresSafeArea()
                    VStack {
                       // Image(.appIcon)
                    }.foregroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        if let _ = AppData.user {
                            navManager.push(screen: .spendings)
                        } else {
                            navManager.push(screen: .login)
                        }

                    })
                }
                .navigationDestination(for: Route.self) { routes in
                    // MARK: - NAVIGATIONS
                    destinationView(for: routes)
                }
            }.disabled(overlayManager.isLoading) // Loading ke waqt touch disable
                .blur(radius: overlayManager.isLoading ? 2 : 0) // Thora blur effect

            // 2. LOADING OVERLAY
            if overlayManager.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
                .transition(.opacity)
            }

            if let popup = overlayManager.popup {
                // Dim Background for Popup
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .zIndex(20)
                    .onTapGesture {
                        // Optional: Background tap pe close karna hai ya nahi
                        // overlayManager.dismissPopup()
                    }

                // The Popup Card
                PopupView(popup: popup)
                    .padding(.horizontal, 30)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(21)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

            if let toast = overlayManager.toast {
                ToastView(toast: toast)
                    .padding(.bottom, 50) // TabBar se thora upar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
                    .id(toast.message)
            }
        }.animation(.spring(response: 0.5, dampingFraction: 0.7), value: overlayManager.toast) // Smooth Animation
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: overlayManager.popup)
            .animation(.easeInOut, value: overlayManager.isLoading)
    }
}


// Helper to pass container down (Optional but recommended)
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: AppDependencyContainer = AppDependencyContainer()
}

extension EnvironmentValues {
    var dependencyContainer: AppDependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
