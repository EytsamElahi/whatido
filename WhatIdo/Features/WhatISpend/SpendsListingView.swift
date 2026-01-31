//
//  SpendsListingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI
import Combine

struct SpendsListingView: View {
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.dependencyContainer) var container
    @ObservedObject var currencyManager = CurrencyManager.shared
    @State private var showCurrencySettingScreen: Bool = false
    @State private var addSpendingVM: AddSpendingViewModel?
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var keyboardHeight: CGFloat = 0

    // MARK: - Filtered Spendings
    private var filteredSpendings: [SpendingDto] {
        guard let spendings = viewModel.currentMonthSpendings else { return [] }
        guard !searchText.isEmpty else { return spendings }

        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        return spendings.filter { spending in
            // Search by name
            if spending.name.lowercased().contains(query) { return true }

            // Search by type/category
            if spending.type.lowercased().contains(query) { return true }

            // Search by amount
            let amountString = String(format: "%.2f", spending.amount)
            if amountString.contains(query) { return true }

            // Search by date
            let dateString = dateFormatter.string(from: spending.date).lowercased()
            if dateString.contains(query) { return true }

            // Search by project name
            if let projectName = spending.project?.projectName?.lowercased(),
               projectName.contains(query) { return true }

            // Search by currency
            if let currency = spending.currencyCode?.lowercased(),
               currency.contains(query) { return true }

            return false
        }
    }

    var budgetProgress: Double {
        let budgetTotal = viewModel.convertedBudgetAmount
        guard budgetTotal > 0 else { return 0 }
        return Double(viewModel.totalSpending) / budgetTotal
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
                    // MARK: - 1. Custom Header (hidden when keyboard shows for search)
                    if !isSearchFocused || keyboardHeight == 0 {
                        AppHeaderView(title: viewModel.currentMonth, trailingButtonIcon: "folder.fill", backAction: {
                            navigation.push(screen: .settings)
                        }, trailingButtonAction: {
                            navigation.push(screen: .projectListing)
                        }, isBackButton: false)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                        // MARK: - 2. Smart Hero Card
                        SpendingsHeroSection(budgetProgress: budgetProgress, progressBarColor: progressBarColor){
                            navigation.push(screen: .spendingAnalytics)
                        }
                        .environmentObject(viewModel)
                        .environmentObject(currencyManager)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    AddSpendingRow()
                        .environmentObject(viewModel)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 5)

                    // MARK: - Search Bar
                    if let spendings = viewModel.currentMonthSpendings, !spendings.isEmpty {
                        SearchBarView(searchText: $searchText, isFocused: $isSearchFocused)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                    }

                    if viewModel.isDataLoading {
                        ProgressView().tint(Color.appPrimaryColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let spendings = viewModel.currentMonthSpendings, spendings.isEmpty {
                        EmptyStateView(
                            icon: "dollarsign.circle",
                            title: "No Expenses Yet",
                            subtitle: "Tap '+' above to record\nyour first expense"
                        )
                    } else {
                        if filteredSpendings.isEmpty && !searchText.isEmpty {
                            // No search results
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                Text("No results for \"\(searchText)\"")
                                    .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                                    .foregroundStyle(Color.textPrimary)
                                Text("Try searching by name, category, amount, or date")
                                    .font(.customFont(family: .quicksand, name: .regular, size: .x14))
                                    .foregroundStyle(Color.textPrimary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                        } else {
                            List {
                                ForEach(filteredSpendings, id: \.id) { spending in
                                    UpdatedSpendingRow(spending: spending)
                                        .environmentObject(currencyManager)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .onTapGesture {
                                            viewModel.prepareEdit(spending: spending)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.spendingToDelete = spending
                                                viewModel.showDeleteConfirmationAlert = true
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                        Spacer()
                    }
                }
                .animation(.easeOut(duration: 0.25), value: isSearchFocused)
            }
            // MARK: - Modifiers & Lifecycle
            .onReceive(Publishers.keyboardHeight) { height in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = height
                }
            }
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
            .onChange(of: viewModel.selectedSortType) { _ in
                viewModel.updatedSorting()
            }
            .onChange(of: viewModel.showAddSheet) { showSheet in
                if showSheet {
                    addSpendingVM = container.makeTransactionFormViewModel(
                        spendingToEdit: viewModel.spendingToEdit,
                        selectedProject: nil
                    )
                } else {
                    // Clean up viewModel when sheet is dismissed (drag/tap outside)
                    addSpendingVM = nil
                }
            }
            .flexibleSheet(isPresented: $viewModel.showAddSheet, minHeight: 420, maxHeight: UIScreen.main.bounds.height * 0.85) {
                if let vm = addSpendingVM {
                    AddSpendingView(viewModel: vm, selectedProject: nil, onSpendingAdded: { [weak viewModel] updatedSpending in
                        viewModel?.showAddSheet = false
                        guard let updatedSpending = updatedSpending else { return }
                        if let index = viewModel?.currentMonthSpendings?.firstIndex(where: { $0.id == updatedSpending.id }) {
                            viewModel?.currentMonthSpendings?[index] = updatedSpending
                        } else {
                            viewModel?.currentMonthSpendings?.append(updatedSpending)
                            viewModel?.updatedSorting()
                        }
                    })
                }
            }
//            .sheet(isPresented: $showCurrencySettingScreen) {
//                SettingsView()
//                    .presentationDetents([.medium])
//            }.interactiveDismissDisabled()
            .sheet(isPresented: $viewModel.showBudgetSheet) {
                SetBudgetView(viewModel: container.makeBudgetViewModel(budgetToEdit: viewModel.monthlyBudget), onGetBudget: { budget in
                    viewModel.monthlyBudget = budget
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.viewModel.showBudgetSheet = false
                    }
                })
            }
            .alert("Confirm Deletion", isPresented: $viewModel.showDeleteConfirmationAlert, presenting: viewModel.spendingToDelete) { spending in
                Button("Delete", role: .destructive) { viewModel.deleteSpending() }
                Button("Cancel", role: .cancel) { viewModel.spendingToDelete = nil }
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
    @EnvironmentObject var viewModel: DashboardViewModel
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
                    //.shadow(color: Color.appPrimaryColor.opacity(0.3), radius: 5, x: 0, y: 2)
            }

            // Sort Menu
            MenuView(listing: viewModel.spendingSortTypes, icon: "slider.horizontal.3", text: "", isPicker: true) { selectedOpt in
                viewModel.selectedSortType = selectedOpt
            }
        }
    }
}
