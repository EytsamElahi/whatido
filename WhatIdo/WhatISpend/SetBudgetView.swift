//
//  SetBudgetView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import SwiftUI

struct SetBudgetView: View {
    @EnvironmentObject var viewModel: SpendingsViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(AppData.budget?[viewModel.currentMonth] ==  nil ? "Set budget for the month" : "Update budget")
                .foregroundStyle(Color.black)
                .font(.customFont(name: .bold, size: .x20))
            AppTextfield(inputText: $viewModel.budgetAmountTf, placeHolder: "Amount", keyboardType: .numberPad)
                .frame(height: 50)
            Spacer()
            VStack {
                if let _ = AppData.budget?[viewModel.currentMonth]  {
                    AppPrimaryButton(title: "Remove budget", cornerPadding: 0, buttonColor: .red, disable: .constant(false), isLoading: $viewModel.isBudgetDeleting, action: {
                        viewModel.deleteBudget()
                    })
                }
                AppPrimaryButton(title: AppData.budget?[viewModel.currentMonth]  ==  nil ? "Set" : "Update", cornerPadding: 0, disable: .constant(false), isLoading: $viewModel.isDataUploading, action: {
                    viewModel.setBudget()
                })
            }
        }.padding()
            .onAppear {
                if let budget = AppData.budget?[viewModel.currentMonth] {
                    viewModel.budgetAmountTf = budget.formatted()
                }
            }
    }
}

#Preview {
    SetBudgetView()
        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
