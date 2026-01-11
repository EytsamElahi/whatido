//
//  SettingsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 11/01/2026.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notification: Bool = false

    private let authService: AuthServiceProtocol
    private let overlayManager = OverlayManager.shared

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func deleteAccount() {
        overlayManager.showPopup(title: "Delete Account?", message: "Are you sure? All your spending data will be lost forever.", style: .warning, primaryAction: PopupAction(title: "Delete", role: .destructive) {
            // TODO: - Add delete account function
        },
        secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
            // Cancel logic (auto dismiss)
        })
    }
}
