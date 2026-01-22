//
//  SpendingHeroSection.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI
struct SpendingsHeroSection: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @EnvironmentObject var currencyManager: CurrencyManager
    var budgetProgress: Double
    var progressBarColor: Color
    var viewAnalyticsAction: () -> Void
    @State private var showInfoTooltip: Bool = false
    @State private var showBudgetTooltip: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if viewModel.isDataLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(spacing: 6) {
                    Text("Total spendings")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                    // Text on Dark BG must be light
                        .foregroundStyle(Color.white.opacity(0.7))
                    
                    if viewModel.hasForeignTransaction {
                        Button {
                            showInfoTooltip.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.5))
                        }
                        .popover(isPresented: $showInfoTooltip) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Estimated Market Rates")
                                    .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                                Text("This total includes foreign transactions converted using estimated market rates. Actual historical value may vary.")
                                    .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 25)
                            .frame(maxWidth: 300)
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    
                    Spacer()
                }
                // Big Amount
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(currencyManager.symbol ?? "")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x20))
                        .foregroundStyle(Color.white.opacity(0.7))

                    Text("\(Int(viewModel.totalSpending))")
                        .font(.customFont(family: .inter, name: .bold, size: .x34))
                        .foregroundStyle(Color.white) // Bright White
                }

                // Progress Bar Section
                if let budget = viewModel.monthlyBudget {
                    VStack(alignment: .leading, spacing: 8) {

                        // Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Track looks good as subtle white on dark
                                Capsule()
                                    .frame(width: geometry.size.width, height: 6)
                                    .foregroundStyle(Color.white.opacity(0.15))

                                // Fill (Green/Orange/Red pops on dark)
                                Capsule()
                                    .frame(width: min(geometry.size.width * budgetProgress, geometry.size.width), height: 6)
                                    .foregroundStyle(progressBarColor)
                            }
                        }
                        .frame(height: 6)

                        // Footer
                        HStack {
                            Button {
                                viewModel.showBudgetSheet.toggle()
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Budget: \(Int(viewModel.convertedBudgetAmount))")
                                        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                                        .foregroundStyle(Color.white.opacity(0.6))
                                        .underline()
                                    
                                    if viewModel.hasForeignBudget {
                                        Button {
                                            showBudgetTooltip.toggle()
                                        } label: {
                                            Image(systemName: "info.circle")
                                                .font(.system(size: 10))
                                                .foregroundStyle(Color.white.opacity(0.5))
                                        }
                                        .popover(isPresented: $showBudgetTooltip) {
                                            VStack(alignment: .leading, spacing: 10) {
                                                Text("Converted Budget")
                                                    .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                                                if let budget = viewModel.monthlyBudget {
                                                    Text("Original Budget: \(Int(budget.budgetAmount)) \(budget.currencyCode ?? "USD"). Converted to match your home currency settings.")
                                                        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: 300)
                                            .presentationCompactAdaptation(.popover)
                                        }
                                    }
                                }
                            }

                            Spacer()

                            let remaining = viewModel.convertedBudgetAmount - viewModel.totalSpending
                            Text(remaining >= 0 ? "\(Int(remaining)) left" : "Over budget")
                                .font(.customFont(family: .quicksand, name: .semiBold, size: .x12))
                            // Remaining is white, Over is red
                                .foregroundStyle(remaining >= 0 ? Color.white.opacity(0.9) : Color.red)
                        }
                    }
                } else {
                    // Set Budget Button (Teal Accent)
                    Button {
                        viewModel.showBudgetSheet.toggle()
                    } label: {
                        Text("Set a Budget")
                            .font(.customFont(family: .quicksand, name: .semiBold, size: .x14))
                            .foregroundStyle(Color.appPrimaryColor) // Teal Text
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1)) // Subtle dark button bg
                            .cornerRadius(8)
                    }
                }

                // View Analytics
                HStack {
                    Spacer()
                    Button {
                        viewAnalyticsAction()
                    } label: {
                        HStack(spacing: 4) {
                            Text("View Analytics")
                            Image(systemName: "arrow.right")
                        }
                        .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                        .foregroundStyle(Color.appPrimaryColor) // Teal accent
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(20)
        // 🔥 MAIN CHANGE: Use Rich Dark Gray
        .background(Color.cardBackground)
        .cornerRadius(24)
        // 🔥 SHADOW FIX: Very subtle, soft shadow. Barely noticeable but adds depth.
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }
}
