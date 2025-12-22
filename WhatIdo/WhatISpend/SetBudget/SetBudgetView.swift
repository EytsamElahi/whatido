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
    var onGetBudget: (Budget?) -> ()

    var body: some View {
        ZStack {
            // 1. Midnight Background
            Color.cardBackground.ignoresSafeArea()

            VStack(spacing: 25) {

                // Header (Drag Indicator)
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .padding(.top, 10)

                Text("Monthly Budget")
                    .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                    .foregroundStyle(Color.white)

                Spacer()

                // MARK: - 1. Huge Amount Input
                VStack(spacing: 10) {
                    Text("Limit")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                        .foregroundStyle(Color.gray)

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("Rs")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x24))
                            .foregroundStyle(Color.appPrimaryColor)

                        TextField("0", value: $budgetInput, format: .number)
                            .keyboardType(.numberPad)
                            .font(.customFont(family: .inter, name: .bold, size: .x50))
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: true, vertical: true)
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

                Spacer()

                // MARK: - 2. Action Buttons
                VStack(spacing: 15) {
                    if viewModel.isUploading {
                        CircularLoadingIndicator(indicatorColor: .white)
                    } else {
                        AppPrimaryButton(title: viewModel.monthlyBudget == nil ? "Set Budget" : "Update Budget", disable: .constant(false), isLoading: .constant(false)) {
                            hideKeyboard()
                            viewModel.budgetAmount = budgetInput
                            viewModel.setOrUpdateBudget()
                        }

                        // Remove Button (Only if budget exists)
                        if viewModel.monthlyBudget != nil {
                            Button {
                                hideKeyboard()
                                viewModel.deleteBudget()
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Remove Budget")
                                }
                                .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                                .foregroundStyle(Color.red)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }.onChange(of: viewModel.budgetUpdated) {
                onGetBudget(viewModel.monthlyBudget)
            }
            // MARK: - Magic Logic 🪄
            .readHeight { height in
                // Content ki height read karke state update karega
                self.sheetHeight = height
            }
        }
        .onAppear {
            // Load existing budget into local state
            if let currentBudget = viewModel.monthlyBudget?.budgetAmount {
                budgetInput = currentBudget
            }
        }
        .interactiveDismissDisabled(viewModel.isUploading)
        .presentationDetents([.height(sheetHeight > 0 ? sheetHeight : 200)])
        .presentationDragIndicator(.hidden)
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
