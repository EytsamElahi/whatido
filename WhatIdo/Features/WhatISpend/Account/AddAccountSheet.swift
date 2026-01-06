//
//  AddAccountSheet.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import SwiftUI

struct AddAccountSheet: View {
    @ObservedObject var viewModel: AccountsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var balance: Double?
    @State private var selectedType: AccountType = .bank
    @State private var selectedAccountTypeString: String = ""
    @State private var sourceId: String = ""

    private var title: String {
        if viewModel.selectedAccount == nil {
            return "New Account"
        } else {
            return "Edit Account"
        }
    }

    private var actionBtnTitle: String {
        if viewModel.selectedAccount == nil {
            return "Add"
        } else {
            return "Update"
        }
    }

    var body: some View {
        ZStack {
            Color.cardBackground.ignoresSafeArea()
            VStack(spacing: 15) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .padding(.top, 10)
                VStack {
                    Text(title)
                        .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                        .foregroundStyle(Color.white)
                    VStack(spacing: 15) {
                        HStack {
                            AppTextfield(inputText: $name, placeHolder: "Account Name", maxLength: 40)
                                .frame(height: 50)

                            CustomPickerView(listing: AccountType.allCases.compactMap { $0.rawValue },
                                             pickedItem: $selectedAccountTypeString)
                            .frame(height: 50)
                        }
                        HStack(spacing: 5) {
                            ZStack(alignment: .leading) {
                                // Dark Background Pill
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.08))
                                HStack {
                                    Text(CurrencyManager.shared.currencyCode)
                                        .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                                        .foregroundStyle(Color.appPrimaryColor)
                                        .padding(.leading, 10)
                                    ZStack(alignment: .leading) {
                                        if balance == nil {
                                            Text("Initial Amount")
                                                .font(.customFont(name: .regular, size: .x16))
                                                .foregroundColor(Color.white.opacity(0.3))
                                                .padding(.leading, 15)
                                                .allowsHitTesting(false)
                                        }
                                        TextField("", value: $balance, format: .number)
                                            .keyboardType(.decimalPad)
                                            .font(.customFont(family: .inter, name: .bold, size: .x16))
                                            .padding(.horizontal, 15)
                                            .foregroundStyle(Color.white)
                                            .tint(Color.appPrimaryColor)
                                        //                                .onChange(of: balance!) {oldValue, newValue in
                                        //                                    if newValue > 999_999_9 {
                                        //                                        balance = 999_999_9
                                        //                                    }
                                        //                                    if newValue < 0 {
                                        //                                        balance = 0
                                        //                                    }
                                        //                                }
                                    }
                                }
                            }.frame(height: 50)

                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Source")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(Color.white)
                            // .padding(.leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.incomeSources, id: \.id) { source in
                                    let selected = source.id == sourceId
                                    Button {
                                        withAnimation {
                                            sourceId = source.id
                                        }
                                    } label: {
                                        CapsuleView(name: source.name, isSelected: selected)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                AppPrimaryButton(title: actionBtnTitle, disable: .constant(balance == nil), isLoading: $viewModel.isLoading) {
                    guard let balance = balance, balance > 0, sourceId != "" else {return}
                    hideKeyboard()
                    actionButton(balance: balance)
                }.padding(.bottom, 20)
                    .disabled(viewModel.isLoading)
            }.padding()
        }.onChange(of: selectedAccountTypeString) {old, new in
            let type = AccountType(rawValue: new)
            self.selectedType = type ?? .bank
        }
        .onAppear {
            if let account = viewModel.selectedAccount {
                self.name = account.name
                self.balance = account.currentBalance
                self.selectedType = account.type
                self.sourceId = account.sourceId
                self.selectedAccountTypeString = account.type.rawValue
            }
        }
        .interactiveDismissDisabled(viewModel.isLoading)
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.hidden)
        .hideKeyboardOnTapAround()

    }

    private func actionButton(balance: Double) {
        if viewModel.selectedAccount == nil {
            viewModel.createAccount(name: name, type: selectedType, balance: balance, sourceId: sourceId)
        } else {
            viewModel.updateAccount(name: name, type: selectedType, balance: balance, sourceId: sourceId)
        }
    }
}

#Preview {
    AddAccountSheet(viewModel: AccountsViewModel(service: AccountService()))
}
