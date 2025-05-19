//
//  AppTextfield.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AppTextfield: View {
    @Binding var inputText: String
    var placeHolder: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        ZStack(content: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
            TextField(text: $inputText) {
                Text(placeHolder)
                    .font(.customFont(name: .regular, size: .x16))
            }
            .keyboardType(keyboardType)
            .font(.customFont(name: .medium, size: .x16))
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .padding(10)
        })
    }
}

#Preview {
    AppTextfield(inputText: .constant(""), placeHolder: "Spending")
}
