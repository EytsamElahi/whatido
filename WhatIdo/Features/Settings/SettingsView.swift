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
    @State private var showFeedbackSheet: Bool = false

    // Helper to get App Version
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // User initials for avatar
    private var userInitials: String {
        let name = viewModel.userName
        if name.isEmpty { return "?" }
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        ZStack {
            // 1. Global Background
            Color.appBackground.ignoresSafeArea()
            VStack {
                AppHeaderView(title: "Settings", backAction: {
                    navigation.pop()
                })
                List {
                    // MARK: - Profile Section
                    Section {
                        Button {
                            viewModel.showProfileSheet = true
                        } label: {
                            HStack(spacing: 14) {
                                // Avatar
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.appPrimaryColor, Color.appPrimaryColor.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)

                                    Text(userInitials)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.userName.isEmpty ? "Set your name" : viewModel.userName)
                                        .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                                        .foregroundStyle(viewModel.userName.isEmpty ? Color.gray : Color.white)

                                    if !viewModel.userEmail.isEmpty {
                                        Text(viewModel.userEmail)
                                            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                            .foregroundStyle(Color.gray)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    // MARK: - Section 1: Preferences
                    Section {
                        // Accounts & Wallets Row
                        SettingsRow(icon: "creditcard.fill", title: "Accounts & Wallets").onTapGesture {
                            navigation.push(screen: .myAccounts)
                        }

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

                    // MARK: - Section 2: Beta Feedback
                    Section {
                        Button {
                            showFeedbackSheet = true
                        } label: {
                            SettingsRow(
                                icon: "bubble.left.and.bubble.right",
                                title: "Send Feedback"
                            )
                        }
                    } header: {
                        Text("Beta Feedback")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                            .foregroundStyle(Color.gray)
                            .padding(.bottom, 5)
                    }
                    .listRowBackground(Color.white.opacity(0.05))

                    // MARK: - Section 3: Support
                    Section {
                        Link(destination: URL(string: "https://fire-cord-c32.notion.site/Yaru-Legal-Support-2ec64ce7ca4c80b595fbcba6ce8c5152")!) {
                            SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy")
                        }
                        
                        Link(destination: URL(string: "mailto:support@yaruapp")!) {
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
                    
                    #if DEBUG
                    // MARK: - Section 4: Developer
                    Section {
                        SettingsRow(icon: "chart.bar.xaxis", title: "Analytics Test")
                            .onTapGesture {
                                navigation.push(screen: .analyticsTest)
                            }
                    } header: {
                        Text("Developer")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                            .foregroundStyle(Color.gray)
                            .padding(.bottom, 5)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    #endif

                    // MARK: - Section 5: Danger Zone
                    Section {
                        Button(role: .destructive) {
                            viewModel.logout()
                        } label: {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", isDestructive: false) // Keep neutral or make red
                        }

                        Button(role: .destructive) {
                            viewModel.reAuthenticate()
                        } label: {
                            SettingsRow(icon: "trash.fill", title: "Delete Account", isDestructive: true)
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
            }
        }.onChange(of: viewModel.accountDeleted) { new in
            if new {
                resetState()
                navigation.path = NavigationPath()
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showFeedbackSheet) {
            FeedbackView(viewModel: FeedbackViewModel(feedbackService: FeedbackService()))
        }
        .sheet(isPresented: $viewModel.showProfileSheet) {
            ProfileSheetView(viewModel: viewModel)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }

    func resetState() {
        AppData.prefCurrency = nil
        AppData.user = nil
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

// MARK: - Profile Sheet View
struct ProfileSheetView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var editableName: String = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Edit Profile")
                .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 20)
                .padding(.bottom, 24)

            VStack(alignment: .leading, spacing: 16) {
                // Email (Read-only)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                        .foregroundStyle(Color.textSecondary)

                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)

                        Text(viewModel.userEmail.isEmpty ? "No email" : viewModel.userEmail)
                            .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                            .foregroundStyle(Color.textSecondary)

                        Spacer()

                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary.opacity(0.5))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                }

                // Name (Editable)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                        .foregroundStyle(Color.textSecondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appPrimaryColor)

                        TextField("Enter your name", text: $editableName)
                            .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                            .foregroundStyle(Color.textPrimary)
                            .focused($isNameFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                saveNameIfChanged()
                            }

                        if editableName != viewModel.userName && !editableName.isEmpty {
                            Button {
                                saveNameIfChanged()
                            } label: {
                                if viewModel.isUpdatingName {
                                    ProgressView()
                                        .tint(Color.appPrimaryColor)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.appPrimaryColor)
                                }
                            }
                            .disabled(viewModel.isUpdatingName)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isNameFocused ? Color.appPrimaryColor : Color.clear, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.appBackground)
        .onAppear {
            editableName = viewModel.userName
        }
    }

    private func saveNameIfChanged() {
        let trimmed = editableName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed != viewModel.userName && !trimmed.isEmpty {
            viewModel.updateUserName(trimmed)
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(authService: FirebaseAuthService(), userRepo: UserRepository()))
}
