//
//  OverlayManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//

import SwiftUI

@MainActor
class OverlayManager: ObservableObject {
    static let shared = OverlayManager()
    private init() {}

    // MARK: - State Properties
    @Published var isLoading: Bool = false
    @Published var toast: Toast?
    @Published var popup: Popup?

    private var toastWorkItem: DispatchWorkItem?

    // MARK: - 1. Loader Functions
    func showLoader() { isLoading = true }
    func hideLoader() { isLoading = false }

    // MARK: - 2. Toast Functions (Auto-Dismiss)
    func showToast(message: String, style: ToastStyle = .info) {
        // Purana pending hide task cancel karo
        toastWorkItem?.cancel()

        withAnimation(.spring()) {
            self.toast = Toast(style: style, message: message)
        }

        // 3 Seconds baad hide karo
        let task = DispatchWorkItem { [weak self] in
            withAnimation(.spring()) {
                self?.toast = nil
            }
        }
        self.toastWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: task)
    }

    // MARK: - 3. Popup Functions (Manual Dismiss)
    func showPopup(title: String, message: String, style: PopupStyle, primaryAction: PopupAction?, secondaryAction: PopupAction? = nil) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            self.popup = Popup(
                title: title,
                message: message,
                style: style,
                primaryAction: primaryAction,
                secondaryAction: secondaryAction
            )
        }
    }

    func dismissPopup() {
        withAnimation(.easeOut(duration: 0.2)) {
            self.popup = nil
        }
    }
}

class PopupMessages {
    static func dataAddedMessage(_ string: String) -> String {
        return "\(string) added successfully"
    }

    static func dataUpdatedMessage(_ string: String) -> String {
        return "\(string) updated successfully"
    }
}
