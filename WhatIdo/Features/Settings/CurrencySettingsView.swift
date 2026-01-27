//
//  SettingsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//


import SwiftUI

struct CurrencySettingsView: View {
    @StateObject var viewModel: CurrencySettingsViewModel
    @EnvironmentObject var navigation: NavigationManager
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
                            ForEach(viewModel.currencies, id: \.code) { (currency: CurrencyOption) in
                                Button {
                                    viewModel.selectCurrency(currency: currency, isFromSettings: isFromSettings)
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

                                            Text("Example: " + viewModel.formatHelper(amount: 1234.56, code: currency.code, locale: currency.locale))
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }

                                        Spacer()

                                        if viewModel.prefCurrencyCode == currency.code {
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
            }.onChange(of: viewModel.navigateToSpendings) { navigate in
                if navigate {
                    navigation.push(screen: .spendings)
                }
            }
            .onChange(of: viewModel.currentSettingApplied) { applied in
                if applied {
                    navigation.pop()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let container = AppDependencyContainer()
    CurrencySettingsView(viewModel: container.makeCurrencySettingsViewModel())
}
