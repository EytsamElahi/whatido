//
//  SpendingHeroSection.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI
struct SpendingsHeroSection: View {
    @EnvironmentObject var viewModel: SpendingsViewModel
    var budgetProgress: Double
    var progressBarColor: Color
    var viewAnalyticsAction: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Total spendings")
                    .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                    .foregroundStyle(Color.gray)
                Spacer()
                if viewModel.isDataLoading {
                    ProgressView()
                        .tint(.white)
                }
            }

            // Big Amount (Inter Font for Numbers)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Rs")
                    .font(.customFont(family: .quicksand, name: .medium, size: .x20))
                    .foregroundStyle(Color.white.opacity(0.7))

                Text("\(Int(viewModel.totalSpending))")
                    .font(.customFont(family: .inter, name: .bold, size: .x34)) // Numbers pop out
                    .foregroundStyle(Color.white)
            }

            // Progress Bar Section
            if let budget = viewModel.budgetAmount {
                VStack(alignment: .leading, spacing: 8) {

                    // Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(width: geometry.size.width, height: 6)
                                .foregroundStyle(Color.white.opacity(0.2))

                            Capsule()
                                .frame(width: min(geometry.size.width * budgetProgress, geometry.size.width), height: 6)
                                .foregroundStyle(progressBarColor)
                        }
                    }
                    .frame(height: 6)

                    // Footer: Budget & Remaining
                    HStack {
                        Button {
                            viewModel.showBudgetSettingSheet.toggle()
                        } label: {
                            Text("Budget: \(Int(budget))")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                                .foregroundStyle(Color.gray)
                                .underline()
                        }

                        Spacer()

                        let remaining = Int(budget) - viewModel.totalSpending
                        Text(remaining >= 0 ? "\(Int(remaining)) left" : "Over budget")
                            .font(.customFont(family: .quicksand, name: .semiBold, size: .x12))
                            .foregroundStyle(remaining >= 0 ? Color.white.opacity(0.8) : Color.red)
                    }
                }
            } else {
                // Setup Budget Button if no budget
                Button {
                    viewModel.showBudgetSettingSheet.toggle()
                } label: {
                    Text("Set a Budget")
                        .font(.customFont(family: .quicksand, name: .semiBold, size: .x14))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }

            // View More Button (Bottom Right of Card)
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
                    .foregroundStyle(Color.white.opacity(0.6))
                }
            }
            .padding(.top, 5)

        }
        .padding(20)
        .background(Color.black)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
