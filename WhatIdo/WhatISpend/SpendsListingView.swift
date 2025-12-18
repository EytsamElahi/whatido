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

    // Progress Bar Logic
    var budgetProgress: Double {
        guard let budget = viewModel.budgetAmount, budget > 0 else { return 0 }
        return Double(viewModel.totalSpending) / budget
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
                        navigation.push(screen: .projectListing(viewModel))
                    })

                    // MARK: - 2. Smart Hero Card
                    SpendingsHeroSection(budgetProgress: budgetProgress, progressBarColor: progressBarColor){
                        navigation.push(screen: .SpendingDetails(SpendingDetailViewModel(spendingService: viewModel.spendingService, currentMonthSpendings: viewModel.currentMonthSpendings, spendingTypes: viewModel.spendingTypes)))
                    }
                    .environmentObject(viewModel)

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
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear) // Important for Gray BG
                                    .onTapGesture {
                                        viewModel.editSpending(spending)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            // Delete Logic: Index dhoond kar delete call karein
                                            if let index = viewModel.currentMonthSpendings?.firstIndex(of: spending) {
                                                viewModel.deleteSpending(at: IndexSet(integer: index))
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
                guard viewModel.currentMonthSpendings == nil else { return }
                let date = Date().getFirstDateOfMonth()
                viewModel.fetchCurrentMonthSpendings(date: date)
            }
            .navigationBarHidden(true) // Using Custom Header
            .onChange(of: viewModel.showAddNewSpendingSheet) { old, new in
                if new == false {
                    viewModel.resetAddSpendingForm()
                    viewModel.tempSpending = nil
                }
            }
            .onChange(of: viewModel.selectedSortType) { _, _ in
                viewModel.updatedSorting()
            }
            .sheet(isPresented: $viewModel.showAddNewSpendingSheet) {
                AddSpendingView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $viewModel.showBudgetSettingSheet) {
                SetBudgetView()
                .environmentObject(viewModel)
//                        // Sirf itni height khulegi jitni zaroorat hai
//                        .presentationDetents([.height(350)])
//                        .presentationDragIndicator(.hidden)
            }
            .alert("Confirm Deletion", isPresented: $viewModel.showConfirmationAlert, presenting: viewModel.spendingToDelete) { spending in
                Button("Delete", role: .destructive) { viewModel.confirmedDeleteSpending() }
                Button("Cancel", role: .cancel) { viewModel.spendingToDelete = nil }
            } message: { _ in
                Text("Are you sure you want to delete this spending?")
            }
        }
    }
}

#Preview {
    SpendsListingView(viewModel: SpendingsViewModel(spendingService: WhatISpendServiceStub()))
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
                viewModel.showAddNewSpendingSheet.toggle()
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
