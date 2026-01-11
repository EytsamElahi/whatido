//
//  SettingsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 11/01/2026.
//


import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @EnvironmentObject var navigation: NavigationManager

    // Helper to get App Version
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            // 1. Global Background
            Color.appBackground.ignoresSafeArea()

            List {
                // MARK: - Section 1: Preferences
                Section {
                    // Currency Row

                    SettingsRow(icon: "banknote", title: "Currency").onTapGesture {
                        navigation.push(screen: .currencySettings(true))
                    }
                    // Notifications Row
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimaryColor.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.appPrimaryColor)
                        }

                        Text("Notifications")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(.white)

                        Spacer()

                        Toggle("", isOn: $viewModel.notification)
                            .tint(Color.appPrimaryColor)
                            .labelsHidden()
                    }
                } header: {
                    Text("Preferences")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                        .foregroundStyle(Color.gray)
                        .padding(.bottom, 5)
                }
                .listRowBackground(Color.white.opacity(0.05)) // Dark Cell Background

                // MARK: - Section 2: Support
                Section {
                    Link(destination: URL(string: "https://whatido.app/privacy")!) {
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy")
                    }

                    Link(destination: URL(string: "mailto:support@whatido.app")!) {
                        SettingsRow(icon: "envelope.fill", title: "Contact Support")
                    }

                    HStack {
                        Text("Version")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(appVersion)
                            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                            .foregroundStyle(.gray)
                    }
                } header: {
                    Text("Support")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                        .foregroundStyle(Color.gray)
                        .padding(.bottom, 5)
                }
                .listRowBackground(Color.white.opacity(0.05))

                // MARK: - Section 3: Danger Zone
                Section {
                    Button(role: .destructive) {
                        // Logout Action
                    } label: {
                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", isDestructive: false) // Keep neutral or make red
                    }

                    Button(role: .destructive) {
                        viewModel.reAuthenticate()
                    } label: {
                        SettingsRow(icon: "trash.fill", title: "Delete My Account", isDestructive: true)
                    }
                } header: {
                    Text("Account")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                        .foregroundStyle(Color.gray)
                        .padding(.bottom, 5)
                } footer: {
                    Text("Deleting your account will permanently remove all your data. This action cannot be undone.")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.top, 5)
                }
                .listRowBackground(Color.red.opacity(0.1)) // Slight red tint for danger zone

            }
            .scrollContentBackground(.hidden) // 🔥 Removes default white list background
            .listStyle(.insetGrouped)
        }.onChange(of: viewModel.accountDeleted) {old, new in
            if new {
                navigation.path = NavigationPath()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 15) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(isDestructive ? Color.red.opacity(0.15) : Color.appPrimaryColor.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isDestructive ? Color.red : Color.appPrimaryColor)
            }

            Text(title)
                .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                .foregroundStyle(isDestructive ? Color.red : Color.white)

            Spacer()

            // Chevron is added automatically by NavigationLink,
            // but for Buttons/Links we might want to add a spacer or custom chevron if needed.
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(authService: FirebaseAuthService()))
}
