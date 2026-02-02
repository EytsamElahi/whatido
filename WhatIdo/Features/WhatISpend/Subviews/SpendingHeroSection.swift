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

  @State private var isExpanded: Bool = AppData.isHeroSectionExpanded
  @State private var showInfoTooltip: Bool = false
  @State private var showBudgetTooltip: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if viewModel.isDataLoading {
        ProgressView()
          .tint(.white)
          .frame(maxWidth: .infinity, minHeight: 80)
      } else {
        // MARK: - Collapsed Header (Always Visible)
        collapsedHeader

        // MARK: - Expandable Content
        if isExpanded {
          expandedContent
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
      }
    }
    .padding(isExpanded ? 20 : 16)
    .background(Color.cardBackground)
    .cornerRadius(isExpanded ? 24 : 18)
    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    .padding(.horizontal)
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
  }

  // MARK: - Collapsed Header View
  private var collapsedHeader: some View {
    HStack(spacing: 12) {
      // Left: Amount Info
      VStack(alignment: .leading, spacing: 2) {
        Text("Total spendings")
          .font(.customFont(family: .quicksand, name: .medium, size: isExpanded ? .x16 : .x12))
          .foregroundStyle(Color.white.opacity(0.7))

        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text(currencyManager.symbol ?? "")
            .font(.customFont(family: .quicksand, name: .medium, size: isExpanded ? .x20 : .x14))
            .foregroundStyle(Color.white.opacity(0.7))

          Text(viewModel.totalSpending.formattedAmount())
            .font(.customFont(family: .inter, name: .bold, size: isExpanded ? .x34 : .x24))
            .foregroundStyle(Color.white)
        }
      }

      Spacer()

      // Right: Collapsed info + Toggle
      HStack(spacing: 12) {
        // Show budget status when collapsed
        if !isExpanded {
          if let _ = viewModel.monthlyBudget {
            let remaining = viewModel.convertedBudgetAmount - viewModel.totalSpending
            let percentLeft = viewModel.convertedBudgetAmount > 0
              ? remaining / viewModel.convertedBudgetAmount
              : 0
            let statusColor = budgetStatusColor(percentLeft: percentLeft)

            VStack(alignment: .trailing, spacing: 2) {
              Text(remaining >= 0 ? "\(remaining.formattedAmount())" : "Over")
                .font(.customFont(family: .inter, name: .bold, size: .x14))
                .foregroundStyle(statusColor)
              Text(remaining >= 0 ? "left" : "budget")
                .font(.customFont(family: .quicksand, name: .semiBold, size: .x10))
                .foregroundStyle(statusColor.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15))
            .cornerRadius(10)
          }

          // Quick Analytics Button when collapsed
          Button {
            viewAnalyticsAction()
          } label: {
            Image(systemName: "chart.pie.fill")
              .font(.system(size: 18))
              .foregroundStyle(Color.appPrimaryColor)
          }
        }

        // Expand/Collapse Toggle
        Button {
          withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isExpanded.toggle()
            AppData.isHeroSectionExpanded = isExpanded
          }
        } label: {
          Image(systemName: "chevron.down")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.6))
            .rotationEffect(.degrees(isExpanded ? 0 : -90))
            .frame(width: 32, height: 32)
            .background(Color.white.opacity(0.1))
            .clipShape(Circle())
        }
      }
    }
  }

  // MARK: - Expanded Content View
  private var expandedContent: some View {
    VStack(alignment: .leading, spacing: 15) {
      // Foreign transaction info
      if viewModel.hasForeignTransaction {
        HStack {
          Button {
            showInfoTooltip.toggle()
          } label: {
            HStack(spacing: 4) {
              Image(systemName: "info.circle")
                .font(.system(size: 12))
              Text("Includes converted amounts")
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
            }
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
          Spacer()
        }
        .padding(.top, 5)
      }

      // Progress Bar Section
      if let _ = viewModel.monthlyBudget {
        VStack(alignment: .leading, spacing: 8) {
          // Bar
          GeometryReader { geometry in
            ZStack(alignment: .leading) {
              Capsule()
                .frame(width: geometry.size.width, height: 6)
                .foregroundStyle(Color.white.opacity(0.15))

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
                Text("Budget: \(viewModel.convertedBudgetAmount.formattedAmount())")
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
                    .foregroundStyle(Color.black)
                    .padding()
                    .frame(maxWidth: 300)
                    .presentationCompactAdaptation(.popover)
                  }
                }
              }
            }

            Spacer()

            let remaining = viewModel.convertedBudgetAmount - viewModel.totalSpending
            Text(remaining >= 0 ? "\(remaining.formattedAmount()) left" : "Over budget")
              .font(.customFont(family: .quicksand, name: .semiBold, size: .x12))
              .foregroundStyle(remaining >= 0 ? Color.white.opacity(0.9) : Color.red)
          }
        }
        .padding(.top, 10)
      } else {
        // Set Budget Section
        Button {
          viewModel.showBudgetSheet.toggle()
        } label: {
          HStack(spacing: 12) {
            ZStack {
              Circle()
                .fill(Color.appPrimaryColor.opacity(0.15))
                .frame(width: 36, height: 36)

              Image(systemName: "chart.bar")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.appPrimaryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
              Text("Set Monthly Budget")
                .font(.customFont(family: .quicksand, name: .semiBold, size: .x14))
                .foregroundStyle(Color.white)

              Text("Stay on track with spending limits")
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
              .font(.system(size: 14, weight: .medium))
              .foregroundStyle(Color.appPrimaryColor)
          }
          .padding(12)
          .background(Color.white.opacity(0.05))
          .cornerRadius(12)
        }
        .padding(.top, 10)
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
          .foregroundStyle(Color.appPrimaryColor)
        }
      }
      .padding(.top, 5)
    }
  }

  // MARK: - Budget Status Color
  private func budgetStatusColor(percentLeft: Double) -> Color {
    switch percentLeft {
    case _ where percentLeft <= 0:
      return .red
    case 0..<0.2:
      return .red
    case 0.2..<0.5:
      return .orange
    default:
      return .green
    }
  }
}
