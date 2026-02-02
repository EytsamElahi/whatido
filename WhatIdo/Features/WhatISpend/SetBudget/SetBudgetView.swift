//
//  SetBudgetView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import SwiftUI

struct SetBudgetView: View {
    @StateObject var viewModel: BudgetViewModel
    // Local state for the input to keep it responsive
    @State private var budgetInput: Double = 0
    // Dynamic Sheet Height ke liye variable
    @State private var sheetHeight: CGFloat = .zero
    @State private var showBudgetInfo: Bool = false
    var onGetBudget: (Budget?) -> ()
    @ObservedObject var currencyManager = CurrencyManager.shared
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header (Drag Indicator)
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundStyle(Color.gray.opacity(0.3))
                .padding(.top, 8)

            HStack(spacing: 8) {
                Text("Monthly Budget")
                    .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                    .foregroundStyle(Color.white)

                if let budget = viewModel.monthlyBudget, (budget.currencyCode ?? "USD") != currencyManager.currencyCode {
                    Button {
                        showBudgetInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.appPrimaryColor)
                    }
                    .popover(isPresented: $showBudgetInfo) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Converted Budget")
                                .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            Text("Original Budget: \(Int(budget.budgetAmount)) \(budget.currencyCode ?? "USD"). Converted to match your home currency settings.")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: 300)
                        .presentationCompactAdaptation(.popover)
                    }
                }
            }

            // MARK: - 1. Amount Input (Compact)
            VStack(spacing: 8) {
                Text("Limit")
                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                    .foregroundStyle(Color.gray)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(currencyManager.currencyCode)
                        .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                        .foregroundStyle(Color.appPrimaryColor)

                    TextField("0", value: $budgetInput, format: .number)
                        .keyboardType(.numberPad)
                        .font(.customFont(family: .inter, name: .bold, size: .x34))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: true)
                        .focused($isAmountFocused)
                        .tint(Color.appPrimaryColor)
                        .onChange(of: budgetInput) { newValue in
                            if newValue > 999_999_9 {
                                budgetInput = 999_999_9
                            }
                            if newValue < 0 {
                                budgetInput = 0
                            }
                        }
                }
            }
            .padding(.vertical, 12)

            // MARK: - 2. Action Buttons
            VStack(spacing: 12) {
                if viewModel.isUploading {
                    CircularLoadingIndicator(indicatorColor: .white)
                        .frame(height: 50)
                } else {
                    AppPrimaryButton(title: viewModel.monthlyBudget == nil ? "Set Budget" : "Update Budget", disable: .constant(false), isLoading: .constant(false)) {
                        hideKeyboard()
                        viewModel.budgetAmount = budgetInput
                        viewModel.setOrUpdateBudget()
                    }

                    // Remove Button (Only if budget exists and not just updated)
                    if viewModel.monthlyBudget != nil && !viewModel.budgetUpdated {
                        Button {
                            hideKeyboard()
                            viewModel.deleteBudget()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Remove Budget")
                            }
                            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                            .foregroundStyle(Color.red)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity) // Stabilize horizontal layout
        .background(Color.cardBackground)
        .onChange(of: viewModel.budgetUpdated) { _ in
            onGetBudget(viewModel.monthlyBudget)
        }
        // MARK: - Magic Logic 🪄
        .readHeight { height in
            // Content ki height read karke state update karega
            self.sheetHeight = height
        }
        .onAppear {
            // Load existing budget into local state (using converted amount from VM)
            if let currentBudget = viewModel.budgetAmount {
                budgetInput = currentBudget
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              isAmountFocused = true
            }
        }
        .interactiveDismissDisabled(viewModel.isUploading)
        .presentationDetents([.height(sheetHeight > 0 ? sheetHeight : 280)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.cardBackground)
        .hideKeyboardOnTapAround()
    }
}

#Preview {
//    SetBudgetView()
//        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}


// 1. Height napne ke liye Preference Key
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// 2. Extension jo use karna asaan banati hai
extension View {
    func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ViewHeightKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(ViewHeightKey.self, perform: onChange)
    }
}
