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
            Text("Set budget")
                .foregroundStyle(Color.black)
                .font(.customFont(name: .bold, size: .x20))
            AppTextfield(inputText: $viewModel.budgetAmountTf, placeHolder: "Amount", keyboardType: .numberPad)
                .frame(height: 50)
            Spacer()
            AppPrimaryButton(title: "Set", cornerPadding: 0, disable: .constant(false), isLoading: $viewModel.isDataUploading, action: {
                 viewModel.setBudget()
            })
        }.padding()
    }
}

#Preview {
    SetBudgetView()
        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
