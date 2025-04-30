//
//  AppPrimaryButton.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AppPrimaryButton: View {
    var title: String
    var cornerPadding: Double? = nil
    var height: Double? = nil
    var fontSize: FontSize? = nil
    @Binding var disable: Bool
    var action: () -> ()
    var body: some View {
        Button(action: {
            action()
        }) {
            Spacer()
            Text(title)
                .foregroundColor(.white)
                .font(.customFont(name: .medium, size: fontSize ?? .x18))
            Spacer()
        }.frame(height: height ?? 51)
            .background(disable ? Color.black.opacity(0.5) : Color.black.opacity(1))
            .cornerRadius(10.0, corners: .allCorners)
            .padding([.leading, .trailing], cornerPadding ?? 20)
            .disabled(disable)

    }
}

#Preview {
    AppPrimaryButton(title: "Login", disable: .constant(false), action: {})
}
