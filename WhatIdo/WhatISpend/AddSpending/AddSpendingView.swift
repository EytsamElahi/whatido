//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AddSpendingView: View {
    @EnvironmentObject var viewModel: SpendingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            Text("Add Spending")
                .foregroundStyle(Color.black)
                .font(.customFont(name: .bold, size: .x20))
            AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "Jot down spending")
                .frame(height: 50)
            HStack {
                AppTextfield(inputText: $viewModel.amountTf, placeHolder: "Amount", keyboardType: .numberPad)
                    .frame(height: 50)
                CalendarFieldView(fieldInputText: $viewModel.dateTf, placeHolder: "Date", datePickerPosition: .start, datePickerRange: .past)
                    .frame(height: 50)
            }
            CustomPickerView(listing: viewModel.spendingTypes.compactMap {$0.name ?? ""}, pickedItem: $viewModel.spendingTypeName)
                .frame(height: 50)
            Spacer()
            AppPrimaryButton(title: "Add", cornerPadding: 0, disable: .constant(false), action: {
                viewModel.addSpending()
            })
        }.padding()
            .background(Color.gray.opacity(0.2))
            .contentShape(Rectangle()) 
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("Error"), message: Text("One of the fields is empty"), dismissButton: .default(Text("Got it!")))
            }
            .hideKeyboardOnTapAround()
    }
}

#Preview {
    AddSpendingView()
        .environmentObject(SpendingsViewModel())
}
