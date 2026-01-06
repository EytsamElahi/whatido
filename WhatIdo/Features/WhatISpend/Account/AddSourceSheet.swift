//
//  AddSourceSheet.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import SwiftUI

struct AddSourceSheet: View {
    @ObservedObject var viewModel: AccountsViewModel
    @State private var name = ""
    @State private var liveIcon = "banknote.fill" // Default Icon

    var body: some View {
        ZStack {
            Color.cardBackground.ignoresSafeArea()
            VStack(spacing: 25) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .padding(.top, 10)

                Text("New Income Source")
                    .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                    .foregroundStyle(Color.white)
                HStack {
                    AppTextfield(inputText: $name, placeHolder: "Source Name (e.g. Salary)", maxLength: 15, leadingIcon: liveIcon)
                        .frame(height: 50)
                        .task(id: name) {
                            if name.isEmpty {
                                liveIcon = "banknote.fill"
                                return
                            }
                            do {
                                try await Task.sleep(nanoseconds: 500_000_000)
                                let newIcon = IncomeSource.getAutoIcon(forName: name)
                                withAnimation {
                                    liveIcon = newIcon
                                }
                            } catch {}
                        }
                }.frame(height: 50)
                AppPrimaryButton(title: "Add", disable: .constant(name == ""), isLoading: $viewModel.isLoading) {
                    guard name != "" else {return}
                    hideKeyboard()
                    viewModel.createSource(name: name)
                }.padding(.bottom, 20)
                    .disabled(viewModel.isLoading)
            }.padding()
        }
        .interactiveDismissDisabled(viewModel.isLoading)
        .presentationDetents([.height(250)])
        .presentationDragIndicator(.hidden)
        .hideKeyboardOnTapAround()

    }
}


#Preview {
    AddSourceSheet(viewModel: AccountsViewModel(service: AccountService()))
}
