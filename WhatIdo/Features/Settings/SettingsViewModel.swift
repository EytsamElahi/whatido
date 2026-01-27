//
//  SettingsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 11/01/2026.
//

import Foundation
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notification: Bool = false
    @Published var accountDeleted: Bool = false

    private let authService: AuthServiceProtocol
    private let userRepo: UserRepositoryType
    private let overlayManager = OverlayManager.shared
    init(authService: AuthServiceProtocol, userRepo: UserRepositoryType) {
        self.authService = authService
        self.userRepo = userRepo
    }

    func deleteAccount() {
        overlayManager.showPopup(title: "Delete Account?", message: "Are you sure? All your spending data will be lost forever.", style: .warning, primaryAction: PopupAction(title: "Delete", role: .destructive) {[weak self] in
            guard let self = self else {return}
            performAccountDeletion()
        },
        secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
            // Cancel logic (auto dismiss)
        })
    }

    func reAuthenticate() {
        overlayManager.showPopup(title: "Action Required", message: "Please re-authenticate using your Signed-In method to continue deleting your account.", style: .info, primaryAction: PopupAction(title: "ReAuthenticate", role: .destructive) {[weak self] in
            guard let self = self else {return}
            let provider = getAuthProvider()
            authenticate(provider)
        },
        secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
            // Cancel logic (auto dismiss)
        })
    }

    func performAccountDeletion() {
        Task {
            overlayManager.showLoader()
            defer { overlayManager.hideLoader() }
            do {
                AppData.clear()
                try await authService.delete()
                self.accountDeleted = true
            } catch {
                debugPrint("Error in deleting")
                overlayManager.showToast(message: error.localizedDescription, style: .error)
            }
        }
    }
    private func authenticate(_ provider: AuthSocialProvider) {
        Task { [weak self] in
            guard let self = self else {return}
            do {
                let _ = try await authService.signIn(with: provider)
                deleteAccount()
            } catch {
                self.overlayManager.showToast(message: error.localizedDescription, style: .error)
            }
        }
    }

    private func getAuthProvider() -> AuthSocialProvider {
        guard let user = Auth.auth().currentUser else { return .unknown }
        for profile in user.providerData {
            switch profile.providerID {
            case AuthSocialProvider.apple.providerID:
                return .apple
            case AuthSocialProvider.google.providerID:
                return .google
            default:
                continue
            }
        }
        return .unknown
    }

    func logout() {
        overlayManager.showPopup(title: "Log Out?", message: "Are you sure you want to log out? Your data will remain safe.", style: .info, primaryAction: PopupAction(title: "Log Out", role: .destructive) {[weak self] in
            guard let self = self else {return}
            performLogout()
        },
        secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
            // Cancel logic (auto dismiss)
        })
    }

    private func performLogout() {
        Task { [weak self] in
            guard let self = self else {return}
            do {
                if let userId = Auth.auth().currentUser?.uid {
                    let _ = await userRepo.updateFCMToken(userId: userId, token: nil)
                }
                AppData.clear()
                try await authService.logout()
                self.accountDeleted = true
            } catch {
                self.overlayManager.showToast(message: error.localizedDescription, style: .error)
            }
        }
    }
}
