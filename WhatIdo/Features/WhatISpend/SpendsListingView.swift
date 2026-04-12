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
  @State private var showAddAccountSheet: Bool = false
  @State private var showNoAccountPopup = false
  @State private var addSpendingVM: AddSpendingViewModel?
  @FocusState private var isSearchFocused: Bool
  @State private var keyboardHeight: CGFloat = 0

  private var progressBarColor: Color {
    if viewModel.budgetProgress >= 1.0 { return .red }
    if viewModel.budgetProgress >= 0.8 { return .orange }
    return .green
  }

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.appBackground.ignoresSafeArea()

        VStack(alignment: .leading) {
          headerSection
          transactionToolbar
          searchBarSection
          contentSection
        }

        if showNoAccountPopup {
          NoAccountPopupView(
            onAddAccount: {
              withAnimation { showNoAccountPopup = false }
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showAddAccountSheet = true
              }
            },
            onSkip: {
              withAnimation { showNoAccountPopup = false }
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                viewModel.showAddSheet = true
              }
            }
          )
          .transition(.opacity)
          .zIndex(100)
        }
      }
      .animation(.easeInOut(duration: 0.3), value: viewModel.showSearchBar)
      .onReceive(Publishers.keyboardHeight) { height in
        withAnimation(.easeOut(duration: 0.25)) {
          keyboardHeight = height
        }
      }
      .onAppear {
        guard viewModel.currentMonthSpendings == nil else { return }
        viewModel.fetchDashboardData()
      }
      .navigationBarHidden(true)
      .onChange(of: viewModel.showAddSheet) { showSheet in
        if showSheet {
          addSpendingVM = container.makeTransactionFormViewModel(
            spendingToEdit: viewModel.spendingToEdit,
            selectedProject: nil
          )
        } else {
          addSpendingVM = nil
        }
      }
      .flexibleSheet(isPresented: $viewModel.showAddSheet, minHeight: 520, maxHeight: UIScreen.main.bounds.height * 0.9) {
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
      .sheet(isPresented: $viewModel.showBudgetSheet) {
        SetBudgetView(viewModel: container.makeBudgetViewModel(budgetToEdit: viewModel.monthlyBudget), onGetBudget: { budget in
          viewModel.monthlyBudget = budget
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewModel.showBudgetSheet = false
          }
        })
      }
      .sheet(isPresented: $showAddAccountSheet) {
        AddAccountSheet(viewModel: container.makeAccountsViewModel())
      }
      .sheet(isPresented: $viewModel.showFilterSheet) {
        SpendingFilterView(
          filters: $viewModel.filters,
          isPresented: $viewModel.showFilterSheet,
          availableCategories: viewModel.availableCategories,
          onApply: { }
        )
      }
      .alert("Confirm Deletion", isPresented: $viewModel.showDeleteConfirmationAlert, presenting: viewModel.spendingToDelete) { _ in
        Button("Delete", role: .destructive) { viewModel.deleteSpending() }
        Button("Cancel", role: .cancel) { viewModel.spendingToDelete = nil }
      } message: { _ in
        Text("Are you sure you want to delete this spending?")
      }
    }
  }

  // MARK: - Sub-sections

  @ViewBuilder
  private var headerSection: some View {
    if !viewModel.showSearchBar {
      AppHeaderView(
        title: viewModel.currentMonth,
        trailingButtonIcon: "folder.fill",
        secondTrailingButtonIcon: "creditcard.fill",
        backAction: { navigation.push(screen: .settings) },
        trailingButtonAction: { navigation.push(screen: .projectListing) },
        secondTrailingButtonAction: { navigation.push(screen: .myAccounts) },
        isBackButton: false
      )
      .transition(.asymmetric(
        insertion: .opacity.combined(with: .move(edge: .top)),
        removal: .opacity
      ))

      SpendingsHeroSection(budgetProgress: viewModel.budgetProgress, progressBarColor: progressBarColor) {
        navigation.push(screen: .spendingAnalytics)
      }
      .environmentObject(viewModel)
      .environmentObject(currencyManager)
      .transition(.asymmetric(
        insertion: .opacity.combined(with: .move(edge: .top)),
        removal: .opacity
      ))
    }
  }

  @ViewBuilder
  private var transactionToolbar: some View {
    AddSpendingRow()
      .environmentObject(viewModel)
      .padding(.horizontal, 20)
      .padding(.top, viewModel.showSearchBar ? 10 : 20)
      .padding(.bottom, 5)
  }

  @ViewBuilder
  private var searchBarSection: some View {
    if viewModel.showSearchBar {
      SearchBarView(
        searchText: $viewModel.searchText,
        isFocused: $isSearchFocused,
        onDismiss: {
          withAnimation(.easeOut(duration: 0.25)) {
            viewModel.showSearchBar = false
          }
        }
      )
      .padding(.horizontal, 20)
      .padding(.bottom, 8)
      .transition(.opacity.combined(with: .scale(scale: 0.95)))
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          isSearchFocused = true
        }
      }
    }
  }

  @ViewBuilder
  private var contentSection: some View {
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
      let filtered = viewModel.filteredSpendings
      if filtered.isEmpty && (!viewModel.searchText.isEmpty || viewModel.filters.isActive) {
        SpendingNoResultsView(searchText: viewModel.searchText, filters: viewModel.filters) {
          withAnimation { viewModel.filters.reset() }
        }
      } else if !filtered.isEmpty {
        spendingsList(filtered)
      }
      Spacer()
    }
  }

  @ViewBuilder
  private func spendingsList(_ spendings: [SpendingDto]) -> some View {
    List {
      ForEach(spendings, id: \.id) { spending in
        UpdatedSpendingRow(spending: spending)
          .environmentObject(currencyManager)
          .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .onTapGesture { viewModel.prepareEdit(spending: spending) }
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

  func didTapAddButton() {
    if viewModel.accounts.isEmpty && !AppData.addAccountPopupShowed {
      AppData.addAccountPopupShowed = true
      withAnimation { showNoAccountPopup = true }
    } else {
      viewModel.spendingToEdit = nil
      viewModel.showAddSheet.toggle()
    }
  }
}

#Preview {
  // SpendsListingView(viewModel: SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}

// MARK: - No Results Sub-View
private struct SpendingNoResultsView: View {
  let searchText: String
  let filters: SpendingFilters
  let onClearFilters: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      Spacer()
      Image(systemName: filters.isActive ? "line.3.horizontal.decrease.circle" : "magnifyingglass")
        .font(.system(size: 40))
        .foregroundStyle(Color.gray.opacity(0.5))

      if !searchText.isEmpty {
        Text("No results for \"\(searchText)\"")
          .font(.customFont(family: .quicksand, name: .medium, size: .x16))
          .foregroundStyle(Color.textPrimary)
      } else {
        Text("No matching transactions")
          .font(.customFont(family: .quicksand, name: .medium, size: .x16))
          .foregroundStyle(Color.textPrimary)
      }

      if filters.isActive {
        Text("Try adjusting your filters")
          .font(.customFont(family: .quicksand, name: .regular, size: .x14))
          .foregroundStyle(Color.textPrimary.opacity(0.7))

        Button(action: onClearFilters) {
          Text("Clear Filters")
            .font(.customFont(family: .quicksand, name: .semiBold, size: .x14))
            .foregroundStyle(Color.appPrimaryColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.appPrimaryColor.opacity(0.15))
            .cornerRadius(20)
        }
        .padding(.top, 8)
      } else {
        Text("Try searching by name, category, amount, or date")
          .font(.customFont(family: .quicksand, name: .regular, size: .x14))
          .foregroundStyle(Color.textPrimary.opacity(0.7))
          .multilineTextAlignment(.center)
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 20)
  }
}
