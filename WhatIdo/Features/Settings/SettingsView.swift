//
//  SettingsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//


import SwiftUI

struct SettingsView: View {
    @StateObject var currencyManager = CurrencyManager.shared
    @EnvironmentObject var navigation: NavigationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack {
                //                // Header
                AppHeaderView(title: "Settings", backAction: {
                    navigation.pop()
                })

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Currency Preference")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        // Currency List
                        VStack(spacing: 0) {
                            ForEach(currencyManager.currencies, id: \.code) { (currency: CurrencyOption) in
                                Button {
                                    currencyManager.updateCurrency(option: currency)
//                                    dismiss.callAsFunction()
                                    navigation.push(screen: .spendings)
                                } label: {
                                    HStack {
                                        Text(currency.symbol)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .frame(width: 40)
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

                                        if currencyManager.currencyCode == currency.code {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.appPrimaryColor)
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
