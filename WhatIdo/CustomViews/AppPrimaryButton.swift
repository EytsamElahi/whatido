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
    var buttonColor: Color? = nil
    @Binding var disable: Bool
    @Binding var isLoading: Bool
    var action: () -> ()
    var body: some View {
        Button(action: {
            action()
        }) {
            Spacer()
            if isLoading {
                CircularLoadingIndicator(indicatorColor: .white)
            } else {
                Text(title)
                    .foregroundColor(.white)
                    .font(.customFont(name: .medium, size: fontSize ?? .x18))
            }
            Spacer()
        }.frame(height: height ?? 51)
            .background(disable ? buttonColor?.opacity(0.5) ?? Color.primary.opacity(0.5) : buttonColor?.opacity(1) ?? Color.primary.opacity(1))
            .cornerRadius(10.0, corners: .allCorners)
            .padding([.leading, .trailing], cornerPadding ?? 20)
            .disabled(disable)

    }
}

#Preview {
    AppPrimaryButton(title: "Login", disable: .constant(false), isLoading: .constant(false), action: {})
}

struct AppSecondaryButton: View {
    var title: String
    var cornerPadding: Double? = nil
    var height: Double? = nil
    var fontSize: FontSize? = nil
    @Binding var disable: Bool
    @Binding var isLoading: Bool
    var action: () -> ()
    var body: some View {
        Button(action: {
            action()
        }) {
            Spacer()
            if isLoading {
                CircularLoadingIndicator(indicatorColor: .white)
            } else {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.customFont(name: .medium, size: fontSize ?? .x18))
            }
            Spacer()
        }.frame(height: height ?? 51)
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(disable ? Color.primary.opacity(0.5) : Color.primary.opacity(1), lineWidth: 2.0)
            )
            .cornerRadius(10.0, corners: .allCorners)
            .padding([.leading, .trailing], cornerPadding ?? 20)
            .disabled(disable)

    }
}

#Preview {
    AppPrimaryButton(title: "Login", disable: .constant(false), isLoading: .constant(false), action: {})
}
