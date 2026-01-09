//
//  SpendsListingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI

struct SpendsListingView: View {
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var viewModel: SpendingsViewModel
    @Environment(\.dependencyContainer) var container
    @ObservedObject var currencyManager = CurrencyManager.shared
    @State private var showCurrencySettingScreen: Bool = false

    // Progress Bar Logic
    var budgetProgress: Double {
        guard let budget = viewModel.monthlyBudget, budget.budgetAmount > 0 else { return 0 }
        return Double(viewModel.totalSpending) / budget.budgetAmount
    }

    var progressBarColor: Color {
            if budgetProgress >= 1.0 { return .red } // Budget exceeded
            if budgetProgress >= 0.8 { return .orange } // Warning
            return .green // Safe
        }

    var body: some View {
        GeometryReader { proxy in
//            VStack(alignment: .leading) {
//                VStack(alignment: .leading) {
//                    // MARK: - 1. Custom Header
//                    AppHeaderView(title: viewModel.currentMonth, backAction: {
//                        print("Button tapped!")
//                    })
//                    // MARK: - 2. Smart Hero Card
//                    SpendingsHeroSection(budgetProgress: budgetProgress, progressBarColor: progressBarColor){
//                        navigation.push(screen: .SpendingDetails(SpendingDetailViewModel(spendingService: viewModel.spendingService, currentMonthSpendings: viewModel.currentMonthSpendings, spendingTypes: viewModel.spendingTypes)))
//                    }
//                        .environmentObject(viewModel)
//                    AddSpendingRow()
//                    .environmentObject(viewModel)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 5)
//                    if viewModel.isDataLoading {
//                        Spacer()
//                        CircularLoadingIndicator()
//                        Spacer()
//                    } else {
//                        List {
//                            ForEach(viewModel.currentMonthSpendings ?? [], id: \.self) { spending in
//                                UpdatedSpendingRow(spending: spending)
//                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
//                                    .listRowSeparator(.hidden)
//                                    .background(Color.clear)
//                                    .onTapGesture {
//                                        viewModel.editSpending(spending)
//                                    }
//                            }
//                            .onDelete(perform: viewModel.deleteSpending)
//                        }
//                        .listStyle(.plain)
//                        .scrollContentBackground(.hidden)
//                        Spacer()
//                    }
//                }
//            }

            ZStack {
                Color.appBackground.ignoresSafeArea() 

                VStack(alignment: .leading) {
                    // MARK: - 1. Custom Header
                    AppHeaderView(title: viewModel.currentMonth, trailingButtonIcon: "folder.fill", backAction: {
                        print("Button tapped!")
                    }, trailingButtonAction: {
                        navigation.push(screen: .projectListing)
                    })

                    // MARK: - 2. Smart Hero Card
                    SpendingsHeroSection(budgetProgress: budgetProgress, progressBarColor: progressBarColor){
                        navigation.push(screen: .myAccounts)
                    }
                    .environmentObject(viewModel)
                    .environmentObject(currencyManager)

                    AddSpendingRow()
                        .environmentObject(viewModel)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 5)

                    if viewModel.isDataLoading {
                        ProgressView().tint(Color.appPrimaryColor) // Loading is now Purple
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.currentMonthSpendings ?? [], id: \.self) { spending in
                                UpdatedSpendingRow(spending: spending)
                                    .environmentObject(currencyManager)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear) // Important for Gray BG
                                    .onTapGesture {
                                        viewModel.prepareEdit(spending: spending)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            // TODO: - Check Deletion is working
                                            // Delete Logic: Index dhoond kar delete call karein
                                            if let index = viewModel.currentMonthSpendings?.firstIndex(of: spending) {
                                                viewModel.spendingToDeleteIndex = index
                                                viewModel.showDeleteConfirmationAlert = true
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        .tint(.red)
                                    }
                            }
                           // .onDelete(perform: viewModel.deleteSpending)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden) // Removes default List gray
                        Spacer()
                    }
                }
            }
            // MARK: - Modifiers & Lifecycle
            .onAppear {
//                if AppData.prefCurrency == nil {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        showCurrencySettingScreen.toggle()
//                    }
//                }
                guard viewModel.currentMonthSpendings == nil else { return }
                viewModel.fetchDashboardData()
            }
            .navigationBarHidden(true) // Using Custom Header
            .onChange(of: viewModel.selectedSortType) { _, _ in
                viewModel.updatedSorting()
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                let addSpendingVM = container.makeTransactionFormViewModel(spendingToEdit: viewModel.spendingToEdit)
                AddSpendingView(viewModel: addSpendingVM, selectedProject: nil,onSpendingAdded: { updatedSpending in
                    self.viewModel.showAddSheet = false
                    guard let updatedSpending = updatedSpending else {return}
                    if let index = viewModel.currentMonthSpendings?.firstIndex(where: { $0.id == updatedSpending.id }) {
                        viewModel.currentMonthSpendings?[index] = updatedSpending
                    } else {
                        viewModel.currentMonthSpendings?.append(updatedSpending)
                        viewModel.updatedSorting()
                    }
                })
                    .presentationDetents([.medium, .large])
            }
//            .sheet(isPresented: $showCurrencySettingScreen) {
//                SettingsView()
//                    .presentationDetents([.medium, .large])
//            }.interactiveDismissDisabled()
            .sheet(isPresented: $viewModel.showBudgetSheet) {
                SetBudgetView(viewModel: container.makeBudgetViewModel(budgetToEdit: viewModel.monthlyBudget), onGetBudget: { budget in
                    viewModel.monthlyBudget = budget
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.viewModel.showBudgetSheet = false
                    }
                })
            }
            .alert("Confirm Deletion", isPresented: $viewModel.showDeleteConfirmationAlert, presenting: viewModel.spendingToDeleteIndex) { spending in
                Button("Delete", role: .destructive) { viewModel.deleteSpending() }
                Button("Cancel", role: .cancel) { viewModel.spendingToDeleteIndex = nil }
            } message: { _ in
                Text("Are you sure you want to delete this spending?")
            }
        }
    }
}

#Preview {
   // SpendsListingView(viewModel: SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}

struct AddSpendingRow: View {
    @EnvironmentObject var viewModel: SpendingsViewModel
    var body: some View {
        HStack {
            Text("Transactions")
                .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            // Add Button
            Button {
                viewModel.spendingToEdit = nil
                viewModel.showAddSheet.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.appPrimaryColor) // Updated Color
                    .shadow(color: Color.appPrimaryColor.opacity(0.3), radius: 5, x: 0, y: 2)
            }

            // Sort Menu
            MenuView(listing: viewModel.spendingSortTypes, icon: "slider.horizontal.3", text: "", isPicker: true) { selectedOpt in
                viewModel.selectedSortType = selectedOpt
            }
        }
    }
}
