//
//  SettingsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//


import SwiftUI

struct CurrencySettingsView: View {
    @StateObject var currencyManager = CurrencyManager.shared
    @ObservedObject var overlayManager = OverlayManager.shared
    @EnvironmentObject var navigation: NavigationManager
    @Environment(\.dependencyContainer) var container
    @Environment(\.dismiss) var dismiss
    var isFromSettings: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack {
                //                // Header
                AppHeaderView(title: "Currency Settings", backAction: {
                    navigation.pop()
                })

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Currency List
                        VStack(spacing: 0) {
                            ForEach(currencyManager.currencies, id: \.code) { (currency: CurrencyOption) in
                                Button {
                                    overlayManager.showPopup(title: "Update Home Currency?",
                                                           message: "Your existing transactions will not be modified. Yaru will recalculate your dashboard totals to display them in \(currency.code).\nNote: Totals are estimates based on today's exchange rates.",
                                                           style: .warning,
                                                           primaryAction: PopupAction(title: "Update", role: nil, action: {
                                        currencyManager.updateCurrency(option: currency)
                                        
                                        // Update on Firestore as well
                                        if let userId = AppData.user?.id {
                                            Task {
                                                let repo = UserRepository()
                                                let _ = await repo.updateUserCurrency(userId: userId, currency: currency.code)
                                            }
                                        }

                                            overlayManager.dismissPopup()
                                            // 📣 Send signal to reload dashboard
                                            container.eventBus.send(.reloadDashboard)
                                            
                                            if isFromSettings {
                                                navigation.pop()
                                            } else {
                                                navigation.push(screen: .spendings)
                                            }
                                        
                                    }), secondaryAction: PopupAction(title: "Cancel", role: .cancel, action: {
                                        overlayManager.dismissPopup()
                                    }))

                                } label: {
                                    HStack(alignment: .top) {
                                        Text(currency.symbol)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .frame(width: 60)
                                            .lineLimit(1)
                                            .foregroundStyle(Color.appPrimaryColor)

                                        VStack(alignment: .leading) {
                                            Text(currency.code)
                                                .font(.headline)
                                                .foregroundStyle(.white)

                                            // 🔥 FIX: Local Helper use kiya hai taake extension error na aye
                                            Text("Example: " + formatHelper(amount: 1234.56, code: currency.code, locale: currency.locale))
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }

                                        Spacer()

                                        if AppData.prefCurrency?.code == currency.code {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.appPrimaryColor)
                                                .padding(.vertical)
                                        }
                                    }
                                    .padding()
                                    .background(Color(white: 0.1))
                                }

                                Divider().background(Color.gray.opacity(0.3))
                            }
                        }
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // 👇 INTERNAL HELPER FUNCTION (Taake 'Double extension' ka error na aye)
    func formatHelper(amount: Double, code: String, locale: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.locale = Locale(identifier: locale)
        return formatter.string(from: NSNumber(value: amount)) ?? "\(code) \(amount)"
    }
}

#Preview {
    CurrencySettingsView()
        .environmentObject(NavigationManager())
}
