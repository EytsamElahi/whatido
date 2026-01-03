//
//  UsernameView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 01/01/2026.
//

import SwiftUI

struct UsernameView: View {
    @State private var name: String = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack {
                VStack(spacing: 10) {
                    Text("Hi there! 👋")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("What should we call you?")
                        .foregroundStyle(.gray)
                }.padding(.top, 10)
                AppTextfield(inputText: $name, placeHolder: "Your Name", maxLength: 30)
                    .frame(height: 50)
                    .padding(.horizontal, 10)

                Spacer()
                VStack(spacing: 15) {
                    AppPrimaryButton(title: "Get Started",
                                     disable: .constant(name.isEmpty),
                                     isLoading: .constant(false)) {
                        viewModel.setUserName(username: name)
                    }
                        .padding(.horizontal)
                        .animation(.easeInOut, value: name.isEmpty)
                    Button(action: {
                        viewModel.setUserName(username: name)
                    }) {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                }
            }
        }.hideKeyboardOnTapAround()
    }
}
