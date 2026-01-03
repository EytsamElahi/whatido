//
//  AppPrimaryButton.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AppPrimaryButton: View {
    var title: String
    var disable: Binding<Bool>
    var isLoading: Binding<Bool>
    var action: () -> ()

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(disable.wrappedValue ? Color.gray : Color.appPrimaryColor)

                if isLoading.wrappedValue {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text(title)
                        .font(.customFont(name: .bold, size: .x18))
                        .foregroundColor(.black) // Black text on Teal is high contrast/premium
                }
            }
            .frame(height: 55)
           // .shadow(color: Color.appPrimaryColor.opacity(disable.wrappedValue ? 0 : 0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .disabled(disable.wrappedValue || isLoading.wrappedValue)
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
                    .foregroundColor(.appPrimaryColor)
                    .font(.customFont(name: .medium, size: fontSize ?? .x18))
            }
            Spacer()
        }.frame(height: height ?? 51)
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(disable ? Color.appPrimaryColor.opacity(0.5) : Color.appPrimaryColor.opacity(1), lineWidth: 2.0)
            )
            .cornerRadius(10.0, corners: .allCorners)
            .padding([.leading, .trailing], cornerPadding ?? 20)
            .disabled(disable)

    }
}

#Preview {
    AppPrimaryButton(title: "Login", disable: .constant(false), isLoading: .constant(false), action: {})
}
