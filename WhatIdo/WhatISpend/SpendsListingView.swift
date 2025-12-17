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
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    // MARK: - 1. Custom Header
                    AppHeaderView(title: viewModel.currentMonth, backAction: {
                        print("Button tapped!")
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
                        CircularLoadingIndicator()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.currentMonthSpendings ?? [], id: \.self) { spending in
                                SpendingRow(spending: spending)
                                    .onTapGesture {
                                        viewModel.editSpending(spending)
                                    }
                                    .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 15)) // Customize spacing here
                            }
                            .onDelete(perform: viewModel.deleteSpending)
                            .listRowSeparator(.hidden)
                            .listRowSpacing(0)
                        }
                        .listStyle(PlainListStyle())
                        Spacer()
                    }
                }
            }.onAppear(perform: {
                guard viewModel.currentMonthSpendings == nil else {return}
                let date = Date().getFirstDateOfMonth()
                viewModel.fetchCurrentMonthSpendings(date: date)
            })
            .navigationBarBackButtonHidden(true)
            .onChange(of: viewModel.showAddNewSpendingSheet) {old, new in
                if new == false {
                    viewModel.resetAddSpendingForm()
                    viewModel.tempSpending = nil
                }
            }.onChange(of: viewModel.selectedSortType) { _ , _ in
                viewModel.updatedSorting()
            }
            .alert("Confirm Deletion",
                     isPresented: $viewModel.showConfirmationAlert,
                     presenting: viewModel.spendingToDelete) { spending in
                  Button("Delete", role: .destructive) {
                      viewModel.confirmedDeleteSpending()
                  }
                  Button("Cancel", role: .cancel) {
                      viewModel.spendingToDelete = nil
                  }
              } message: { spending in
                  Text("Are you sure you want to delete spending?")
              }
            .sheet(isPresented: $viewModel.showAddNewSpendingSheet) {
                AddSpendingView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
             }
            .sheet(isPresented: $viewModel.showBudgetSettingSheet) {
                SetBudgetView()
                    .environmentObject(viewModel)
                    .presentationDetents([.height(viewModel.monthlyBudget == nil ? 200 : 300)])
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
            Spacer()
            // Add Button
            Button {
                viewModel.showAddNewSpendingSheet.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.black) // Use App Primary Color
            }
            // Sort Menu
            // MARK: - 3. Add Button (Floating Style or Below Card)
            MenuView(listing: viewModel.spendingSortTypes, icon: "slider.horizontal.3", text: "", isPicker: true) { selectedOpt in
                viewModel.selectedSortType = selectedOpt
            }
        }
    }
}
