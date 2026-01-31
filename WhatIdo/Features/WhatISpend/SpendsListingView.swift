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
    @State private var filters: SpendingFilters = SpendingFilters()
    @State private var showFilterSheet: Bool = false
    @State private var sortOption: SpendingSortOption = .default

    // MARK: - Available Categories (extracted from spendings)
    private var availableCategories: [String] {
        guard let spendings = viewModel.currentMonthSpendings else { return [] }
        let categories = Set(spendings.map { $0.type })
        return Array(categories).sorted()
    }

    // MARK: - Filtered & Sorted Spendings
    private var filteredSpendings: [SpendingDto] {
        guard let spendings = viewModel.currentMonthSpendings else { return [] }

        var result = spendings

        // Apply filters first
        result = applyFilters(to: result)

        // Then apply search
        if !searchText.isEmpty {
            result = applySearch(to: result)
        }

        // Finally apply sorting
        result = result.sorted(by: sortOption)

        return result
    }

    private func applyFilters(to spendings: [SpendingDto]) -> [SpendingDto] {
        var result = spendings

        // Date Range Filter
        if filters.dateRange != .all {
            let calendar = Calendar.current
            let now = Date()

            result = result.filter { spending in
                switch filters.dateRange {
                case .all:
                    return true
                case .today:
                    return calendar.isDateInToday(spending.date)
                case .last7Days:
                    guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return true }
                    return spending.date >= sevenDaysAgo
                case .last14Days:
                    guard let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: now) else { return true }
                    return spending.date >= fourteenDaysAgo
                case .thisWeek:
                    return calendar.isDate(spending.date, equalTo: now, toGranularity: .weekOfYear)
                }
            }
        }

        // Amount Range Filter
        if filters.amountRange != .all {
            result = result.filter { filters.amountRange.matches(amount: $0.amount) }
        }

        // Category Filter
        if !filters.categories.isEmpty {
            result = result.filter { filters.categories.contains($0.type) }
        }

        // Fund Source Filter
        if !filters.fundSources.isEmpty {
            result = result.filter { spending in
                guard let fundSource = spending.fundSource else { return false }
                return filters.fundSources.contains(fundSource)
            }
        }

        // Project Filter
        if filters.hasProject != .all {
            result = result.filter { spending in
                // Check if project has a valid id (not just exists as empty object)
                let hasValidProject = spending.project?.id != nil && !(spending.project?.id?.isEmpty ?? true)

                switch filters.hasProject {
                case .all:
                    return true
                case .withProject:
                    return hasValidProject
                case .withoutProject:
                    return !hasValidProject
                }
            }
        }

        return result
    }

    private func applySearch(to spendings: [SpendingDto]) -> [SpendingDto] {
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

                    AddSpendingRow(filters: $filters, showFilterSheet: $showFilterSheet, sortOption: $sortOption)
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
                        if filteredSpendings.isEmpty && (!searchText.isEmpty || filters.isActive) {
                            // No results from search or filters
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

                                    Button {
                                        withAnimation {
                                            filters.reset()
                                        }
                                    } label: {
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
                        } else if !filteredSpendings.isEmpty {
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
            .sheet(isPresented: $showFilterSheet) {
                SpendingFilterView(
                    filters: $filters,
                    isPresented: $showFilterSheet,
                    availableCategories: availableCategories,
                    onApply: { }
                )
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
    @Binding var filters: SpendingFilters
    @Binding var showFilterSheet: Bool
    @Binding var sortOption: SpendingSortOption

    private var isNotDefaultSort: Bool {
        sortOption.field != .date || sortOption.direction != .descending
    }

    var body: some View {
        VStack(spacing: 12) {
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
                        .foregroundStyle(Color.appPrimaryColor)
                }

                // Filter Button
                Button {
                    showFilterSheet = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: filters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(filters.isActive ? Color.appPrimaryColor : Color.gray)

                        if filters.activeFilterCount > 0 {
                            Text("\(filters.activeFilterCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 16, height: 16)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
                }

                // Sort Menu
                SortMenuView(currentSort: $sortOption) { }
            }

            // Active Filters/Sort Info Row
            if filters.isActive || isNotDefaultSort {
                HStack {
                    // Show current sort if not default
                    if isNotDefaultSort {
                        HStack(spacing: 4) {
                            Image(systemName: sortOption.field.icon)
                                .font(.system(size: 10))
                            Text(sortOption.displayName)
                                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                        }
                        .foregroundStyle(Color.appPrimaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimaryColor.opacity(0.15))
                        .cornerRadius(12)
                    }

                    // Show filter count
                    if filters.isActive {
                        Text("\(filters.activeFilterCount) filter\(filters.activeFilterCount > 1 ? "s" : "")")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                            .foregroundStyle(Color.gray)
                    }

                    Spacer()

                    // Reset All Button
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            filters.reset()
                            sortOption = .default
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                            Text("Reset All")
                                .font(.customFont(family: .quicksand, name: .semiBold, size: .x12))
                        }
                        .foregroundStyle(Color.red)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: filters.isActive)
        .animation(.easeOut(duration: 0.2), value: sortOption)
    }
}
