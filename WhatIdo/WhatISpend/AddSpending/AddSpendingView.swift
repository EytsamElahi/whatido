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
        VStack{
            AppTextfield(inputText: $textfieldInput, placeHolder: "Jot down spending")
                .frame(height: 50)
            HStack {
                AppTextfield(inputText: $amountTextfieldInput, placeHolder: "Amount")
                    .frame(height: 50)
                AppTextfield(inputText: $dateTextfieldInput, placeHolder: "Amount")
                    .frame(height: 50)
            }
            AppPrimaryButton(title: "Add", cornerPadding: 0, disable: .constant(false), action: {})
        }.padding(10)
    }
}

#Preview {
    AddSpendingView()
}
