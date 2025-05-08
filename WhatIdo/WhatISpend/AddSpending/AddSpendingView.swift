//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AddSpendingView: View {
    @State var textfieldInput: String = ""
    @State var amountTextfieldInput: String = ""
    @State var dateTextfieldInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            Text("Add Spending")
                .foregroundStyle(Color.black)
                .font(.customFont(name: .bold, size: .x20))
            AppTextfield(inputText: $textfieldInput, placeHolder: "Jot down spending")
                .frame(height: 50)
            HStack {
                AppTextfield(inputText: $amountTextfieldInput, placeHolder: "Amount")
                    .frame(height: 50)
                CalendarFieldView(fieldInputText: $dateTextfieldInput, placeHolder: "Date", datePickerPosition: .start, datePickerRange: .future)
                    .frame(height: 50)
            }
            AppPickerView()
                .frame(height: 50)
            Spacer()
            AppPrimaryButton(title: "Add", cornerPadding: 0, disable: .constant(false), action: {})
        }.padding()
    }
}

#Preview {
    AddSpendingView()
}
