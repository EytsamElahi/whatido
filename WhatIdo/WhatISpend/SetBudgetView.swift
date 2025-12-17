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
            Text(viewModel.monthlyBudget ==  nil ? "Set budget for the month" : "Update budget")
                .foregroundStyle(Color.black)
                .font(.customFont(name: .bold, size: .x20))
            AppTextfield(inputText: $viewModel.budgetAmountTf, placeHolder: "Amount", keyboardType: .numberPad)
                .frame(height: 50)
            Spacer()
            VStack {
                AppPrimaryButton(title: viewModel.monthlyBudget == nil ? "Set" : "Update", cornerPadding: 0, disable: .constant(false), isLoading: $viewModel.isDataUploading, action: {
                    viewModel.setOrUpdateBudget()
                })
                if let _ = viewModel.monthlyBudget  {
                    AppPrimaryButton(title: "Remove budget", cornerPadding: 0, buttonColor: .red, disable: .constant(false), isLoading: $viewModel.isBudgetDeleting, action: {
                        viewModel.deleteBudget()
                    })
                }
            }
        }.padding()
            .onAppear {
                if let budget = viewModel.monthlyBudget {
                    viewModel.budgetAmountTf = budget.budgetAmount.formatted()
                }
            }
    }
}

#Preview {
    SetBudgetView()
        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
