//
//  OverlayManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 22/12/2025.
//

import SwiftUI

@MainActor
class OverlayManager: ObservableObject {
    // Singleton (Recommended approach humne decide ki thi)
    static let shared = OverlayManager()
    private init() {}

    @Published var toast: Toast?
    @Published var isLoading: Bool = false

    // Work item ko store karenge taake cancel kar sakein agar naya toast aye
    private var workItem: DispatchWorkItem?

    func showToast(message: String, style: ToastStyle = .info) {
        // 1. Agar pehle se koi work pending hai to cancel karo
        workItem?.cancel()

        // 2. Naya Toast set karo
        withAnimation(.spring()) {
            self.toast = Toast(style: style, message: message)
        }

        // 3. Auto-Hide Logic (3 seconds baad)
        let task = DispatchWorkItem { [weak self] in
            withAnimation(.spring()) {
                self?.toast = nil
            }
        }

        self.workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: task)
    }

    func showLoader() { isLoading = true }
    func hideLoader() { isLoading = false }
}
