//
//  CurrencySettingsViewModel.swift
//  WhatIdo
//
//  Created by antigravity on 27/01/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CurrencySettingsViewModel: ObservableObject {
    @Published var currencies: [CurrencyOption]
    @Published var navigateToSpendings: Bool = false
    @Published var currentSettingApplied: Bool = false
    private let currencyManager: CurrencyManager
    private let userRepo: UserRepositoryType
    private let overlayManager: OverlayManager = .shared
    private let eventBus: PassthroughSubject<AppGlobalEvent, Never>
    private let analytics = AnalyticsManager.shared
    
    init(currencyManager: CurrencyManager = .shared,
         userRepo: UserRepositoryType,
         eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
        self.currencyManager = currencyManager
        self.userRepo = userRepo
        self.eventBus = eventBus
        self.currencies = currencyManager.currencies
    }
    
    var prefCurrencyCode: String {
        return AppData.prefCurrency?.code ?? ""
    }
    
    func selectCurrency(currency: CurrencyOption, isFromSettings: Bool) {
        if isFromSettings {
            showUpdatePopup(for: currency)
        } else {
            performUpdate(currency: currency)
            navigateToSpendings.toggle()
        }
    }
    
    private func showUpdatePopup(for currency: CurrencyOption) {
        overlayManager.showPopup(
            title: "Update Home Currency?",
            message: "Your existing transactions will not be modified. Yaru will recalculate your dashboard totals to display them in \(currency.code).\nNote: Totals are estimates based on today's exchange rates.",
            style: .warning,
            primaryAction: PopupAction(title: "Update", role: nil, action: { [weak self] in
                guard let self = self else { return }
                self.performUpdate(currency: currency)
                self.overlayManager.dismissPopup()
                self.eventBus.send(.reloadDashboard)
                self.currentSettingApplied.toggle()
            }),
            secondaryAction: PopupAction(title: "Cancel", role: .cancel, action: { [weak self] in
                self?.overlayManager.dismissPopup()
            })
        )
    }
    
    private func performUpdate(currency: CurrencyOption) {
        let previousCurrency = currencyManager.activeCurrency?.code ?? "USD"
        currencyManager.updateCurrency(option: currency)

        // Log analytics event
        analytics.logCurrencyChanged(from: previousCurrency, to: currency.code)

        // Update on Firestore as well
        if let userId = AppData.user?.id {
            Task {
                let _ = await userRepo.updateUserCurrency(userId: userId, currency: currency.code)
            }
        }
    }
    
    func formatHelper(amount: Double, code: String, locale: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = Locale(identifier: locale)
        return formatter.string(from: NSNumber(value: amount)) ?? "\(code) \(amount)"
    }
}
