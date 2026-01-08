//
//  AccountsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import SwiftUI

struct AccountsView: View {
    @StateObject var viewModel: AccountsViewModel
    @State private var selectedTab = 0 // 0: Accounts, 1: Sources
    @EnvironmentObject var navigation: NavigationManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                AppHeaderView(title: "Accounts", backAction: {
                    navigation.pop()
                })
                VStack(spacing: 20) {
                    // 1. HEADER: Total Net Worth
                    VStack(spacing: 5) {
                        Text("Total Balance")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text("\(CurrencyManager.shared.currencyCode) \(viewModel.totalBalance, specifier: "%.0f")")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    //.padding(.top, 20)

                    // 2. SEGMENTED CONTROL (Custom Style recommended but using native for speed)
                    Picker("", selection: $selectedTab) {
                        Text("Accounts").tag(0)
                        Text("Income Sources").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onAppear {
                        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appPrimaryColor)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                    }

                    // 3. LIST CONTENT
                    //  ScrollView {
                        if selectedTab == 0 {
                            ScrollView {
                                VStack(spacing: 20) {
                                    ForEach(viewModel.accounts, id: \.self) { account in
                                        AccountCardView(account: account, onEdit: {
                                            viewModel.editAccount(account)
                                        }, onDelete: {
                                            viewModel.deleteAccount(account.id)
                                        }, onBalanceAdjustment: {
                                            viewModel.selectedAccount = account
                                            viewModel.showAdjustSheet.toggle()
                                        }, onMarkAsDefault: {
                                            viewModel.markAsDefault(account: account)
                                        })
                                    }
                                }
                            }
                            .padding()
                        } else {
                            List {
                                ForEach(viewModel.incomeSources, id: \.self) { source in
                                    SourceRowView(source: source)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .onTapGesture {
                                            viewModel.editSource(source)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                if let index = viewModel.incomeSources.firstIndex(of: source) {
                                                    viewModel.deleteIncomeSource(index)
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                            .tint(.red)
                                        }
                                }
                            }.id(viewModel.listRefreshID)
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                   // }
                }
            }

            // 4. FAB BUTTON (Bottom Right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.openSheet(tab: selectedTab)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(Color.appPrimaryColor)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }.navigationBarBackButtonHidden()
        .onAppear {
           viewModel.fetchData()
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            if selectedTab == 0 {
                AddAccountSheet(viewModel: viewModel)
            } else {
                AddSourceSheet(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showAdjustSheet) {
            AdjustBalanceSheet(viewModel: viewModel)
        }
    }
}

// Simple Row for Income Source
struct SourceRowView: View {
    let source: IncomeSourceDto
    
    var body: some View {
        HStack {
            Image(systemName: source.icon)
                .font(.title2)
                .foregroundColor(Color.appPrimaryColor)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
            
            Text(source.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(uiColor: .systemGray6).opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AccountsView(viewModel: AccountsViewModel(service: AccountService()))
}

struct AdjustBalanceSheet: View {
    @ObservedObject var viewModel: AccountsViewModel
    @State private var newBalance: Double? = nil
    @State private var newBalanceString: String = ""

    var body: some View {
        ZStack {
            Color.cardBackground.ignoresSafeArea()
            VStack(spacing: 15) {
                // Drag Indicator
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .padding(.top, 10)

                VStack(spacing: 10) {
                    // Title
                    Text("Adjust Balance")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                        .foregroundStyle(Color.white)

                    // Current Balance Info (ReadOnly Display)
                    VStack(spacing: 5) {
                        Text("Current Recorded Balance")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                            .foregroundStyle(Color.gray)

                        Text("\(CurrencyManager.shared.symbol) \(viewModel.selectedAccount?.currentBalance ?? 0, specifier: "%.2f")")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x24))
                            .foregroundStyle(Color.appPrimaryColor)
                    }
                    .padding(.vertical, 10)

                    // Input Field for New Balance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("New Actual Balance")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(Color.white)

                        // Using your custom AppTextfield for consistency
                        AppTextfield(inputText: $newBalanceString,
                                     placeHolder: "Enter actual amount...", keyboardType: .decimalPad)
                            .frame(height: 50)
                    }
                }

                Spacer()

                // Action Button
                AppPrimaryButton(
                    title: "Confirm Adjustment",
                    disable: .constant(newBalanceString.isEmpty),
                    isLoading: $viewModel.isLoading
                ) {
                    hideKeyboard()
                    if let val = Double(newBalanceString) {
                        viewModel.adjustAccountBalance(to: val)
                    }
                }
                .padding(.vertical, 10)
                .disabled(viewModel.isLoading)

            }
            .padding()
        }
        .onAppear {
            if let current = viewModel.selectedAccount?.currentBalance {
                newBalanceString = String(format: "%.0f", current)
            }
        }
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.hidden)
    }
}
