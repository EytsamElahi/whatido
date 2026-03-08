//
//  ProjectSpendingsListView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

struct ProjectSpendingsListView: View {
    @EnvironmentObject var navigation: NavigationManager
    let project: ProjectDto
    @StateObject var viewModel: ProjectsViewModel
    @Environment(\.dependencyContainer) var container
    @ObservedObject var currencyManager = CurrencyManager.shared
    @State private var addSpendingVM: AddSpendingViewModel?
    @State private var searchText: String = ""
    @State private var filters: SpendingFilters = SpendingFilters()
    @State private var showFilterSheet: Bool = false
    @State private var sortOption: SpendingSortOption = .default
    @FocusState private var isSearchFocused: Bool
    @State private var keyboardHeight: CGFloat = 0

    // MARK: - Available Categories
    private var availableCategories: [String] {
        guard let spendings = viewModel.projectSpendings else { return [] }
        let categories = Set(spendings.map { $0.type })
        return Array(categories).sorted()
    }

    // MARK: - Filtered & Sorted Spendings
    private var filteredSpendings: [SpendingDto] {
        guard let spendings = viewModel.projectSpendings else { return [] }

        var result = spendings

        // Apply filters
        result = applyFilters(to: result)

        // Apply search
        if !searchText.isEmpty {
            result = applySearch(to: result)
        }

        // Apply sorting
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

        // Fund Source Filter — disabled (source field removed from UI)
//        if !filters.fundSources.isEmpty {
//            result = result.filter { spending in
//                guard let fundSource = spending.fundSource else { return false }
//                return filters.fundSources.contains(fundSource)
//            }
//        }

        // Skip project filter - already in project context

        return result
    }

    private func applySearch(to spendings: [SpendingDto]) -> [SpendingDto] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        return spendings.filter { spending in
            if spending.name.lowercased().contains(query) { return true }
            if spending.type.lowercased().contains(query) { return true }

            let amountString = String(format: "%.2f", spending.amount)
            if amountString.contains(query) { return true }

            let dateString = dateFormatter.string(from: spending.date).lowercased()
            if dateString.contains(query) { return true }

            if let currency = spending.currencyCode?.lowercased(),
               currency.contains(query) { return true }

            return false
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header (hidden when search focused)
                if !isSearchFocused || keyboardHeight == 0 {
                    HStack {
                        Button(action: {
                            navigation.pop()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: project.icon)
                                .foregroundStyle(Color.appPrimaryColor)
                            Text(project.name)
                                .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                                .foregroundStyle(Color.white)
                        }
                        .padding(.leading, 8)

                        Spacer()

                        Button {
                            viewModel.selectedProject = project
                            viewModel.spendingToEdit = nil
                            viewModel.showAddNewSpendingSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(viewModel.isDataLoading ? Color.appPrimaryColor.opacity(0.3) : Color.appPrimaryColor)
                        }
                        .disabled(viewModel.isDataLoading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    // MARK: - Total Spent Card
                    if let spendings = viewModel.projectSpendings, !spendings.isEmpty {
                        VStack(spacing: 5) {
                            Text("Total Spent")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                .foregroundStyle(Color.gray)

                            Text("\(currencyManager.symbol ?? "") \(viewModel.totalProjectSpending)")
                                .font(.customFont(family: .inter, name: .bold, size: .x30))
                                .foregroundStyle(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.cardBackground)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // MARK: - Transactions Header with Filter
                if let spendings = viewModel.projectSpendings, !spendings.isEmpty {
                    ProjectTransactionsHeader(
                        filters: $filters,
                        showFilterSheet: $showFilterSheet,
                        sortOption: $sortOption
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // MARK: - Search Bar
                    SearchBarView(searchText: $searchText, isFocused: $isSearchFocused)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                // MARK: - Content
                if viewModel.isDataLoading {
                    Spacer()
                    ProgressView().tint(Color.appPrimaryColor)
                    Spacer()
                } else if let spendings = viewModel.projectSpendings {
                    if spendings.isEmpty {
                        EmptyStateView(
                            icon: "dollarsign.circle",
                            title: "No Expenses Yet",
                            subtitle: "Tap '+' to add expenses\nto this project",
                            buttonTitle: "Add Expense"
                        ) {
                            viewModel.selectedProject = project
                            viewModel.spendingToEdit = nil
                            viewModel.showAddNewSpendingSheet = true
                        }
                    } else if filteredSpendings.isEmpty && (!searchText.isEmpty || filters.isActive) {
                        // No results from search/filters
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: filters.isActive ? "line.3.horizontal.decrease.circle" : "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.gray.opacity(0.5))

                            Text(!searchText.isEmpty ? "No results for \"\(searchText)\"" : "No matching transactions")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                                .foregroundStyle(Color.textPrimary)

                            if filters.isActive {
                                Text("Try adjusting your filters")
                                    .font(.customFont(family: .quicksand, name: .regular, size: .x14))
                                    .foregroundStyle(Color.textPrimary.opacity(0.7))

                                Button {
                                    withAnimation { filters.reset() }
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
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredSpendings, id: \.id) { spending in
                                    UpdatedSpendingRow(spending: spending, hideProject: true)
                                        .environmentObject(currencyManager)
                                        .background(Color.cardBackground)
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            viewModel.spendingToEdit = spending
                                            viewModel.selectedProject = project
                                            viewModel.showAddNewSpendingSheet = true
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                // Handle delete if needed
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .animation(.easeOut(duration: 0.25), value: isSearchFocused)
        }
        .navigationBarHidden(true)
        .onReceive(Publishers.keyboardHeight) { height in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = height
            }
        }
        .onAppear {
            viewModel.fetchProjectSpendings(project.id)
        }
        .onChange(of: viewModel.showAddNewSpendingSheet) { showSheet in
            if showSheet {
                addSpendingVM = container.makeTransactionFormViewModel(
                    spendingToEdit: viewModel.spendingToEdit,
                    selectedProject: viewModel.selectedProject
                )
            } else {
                // Clean up viewModel when sheet is dismissed
                addSpendingVM = nil
            }
        }
        .flexibleSheet(isPresented: $viewModel.showAddNewSpendingSheet, minHeight: 420, maxHeight: UIScreen.main.bounds.height * 0.65) {
            if let vm = addSpendingVM {
                AddSpendingView(viewModel: vm, selectedProject: viewModel.selectedProject, onSpendingAdded: { [weak viewModel] updatedSpending in
                    viewModel?.showAddNewSpendingSheet = false
                    guard let updatedSpending = updatedSpending else { return }
                    if let index = viewModel?.projectSpendings?.firstIndex(where: { $0.id == updatedSpending.id }) {
                        viewModel?.projectSpendings?[index] = updatedSpending
                    } else {
                        viewModel?.projectSpendings?.insert(updatedSpending, at: 0)
                    }
                    Task { [weak viewModel] in
                        guard let viewModel else { return }
                        await viewModel.updateTotalSpending()
                    }
                })
                .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            ProjectSpendingFilterView(
                filters: $filters,
                isPresented: $showFilterSheet,
                availableCategories: availableCategories,
                onApply: { }
            )
        }
    }
}

// MARK: - Project Transactions Header
struct ProjectTransactionsHeader: View {
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
                    .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // Filter Button
                Button {
                    showFilterSheet = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: filters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
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

                    if filters.isActive {
                        Text("\(filters.activeFilterCount) filter\(filters.activeFilterCount > 1 ? "s" : "")")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                            .foregroundStyle(Color.gray)
                    }

                    Spacer()

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

// MARK: - Project Spending Filter View (without project filter)
struct ProjectSpendingFilterView: View {
    @Binding var filters: SpendingFilters
    @Binding var isPresented: Bool
    let availableCategories: [String]
    let onApply: () -> Void

    @State private var tempFilters: SpendingFilters = SpendingFilters()

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Date Range
                        filterSection(title: "Date Range", icon: "calendar") {
                            FlowLayout(spacing: 8) {
                                ForEach(DateRangeFilter.allCases) { option in
                                    FilterChip(
                                        title: option.rawValue,
                                        isSelected: tempFilters.dateRange == option
                                    ) {
                                        tempFilters.dateRange = option
                                    }
                                }
                            }
                        }

                        // Amount Range
                        filterSection(title: "Amount Range", icon: "dollarsign.circle") {
                            FlowLayout(spacing: 8) {
                                ForEach(AmountRangeFilter.allCases) { option in
                                    FilterChip(
                                        title: option.rawValue,
                                        isSelected: tempFilters.amountRange == option
                                    ) {
                                        tempFilters.amountRange = option
                                    }
                                }
                            }
                        }

                        // Categories
                        if !availableCategories.isEmpty {
                            filterSection(title: "Category", icon: "tag") {
                                FlowLayout(spacing: 8) {
                                    ForEach(availableCategories, id: \.self) { category in
                                        FilterChip(
                                            title: category,
                                            isSelected: tempFilters.categories.contains(category)
                                        ) {
                                            if tempFilters.categories.contains(category) {
                                                tempFilters.categories.remove(category)
                                            } else {
                                                tempFilters.categories.insert(category)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Fund Source — disabled (source field removed from UI)
//                        filterSection(title: "Payment Method", icon: "creditcard") {
//                            FlowLayout(spacing: 8) {
//                                ForEach(FundSource.allCases, id: \.self) { source in
//                                    FilterChip(
//                                        title: source.rawValue,
//                                        isSelected: tempFilters.fundSources.contains(source)
//                                    ) {
//                                        if tempFilters.fundSources.contains(source) {
//                                            tempFilters.fundSources.remove(source)
//                                        } else {
//                                            tempFilters.fundSources.insert(source)
//                                        }
//                                    }
//                                }
//                            }
//                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(Color.gray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if tempFilters.isActive {
                        Button("Reset") {
                            tempFilters.reset()
                        }
                        .foregroundStyle(Color.red)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    filters = tempFilters
                    onApply()
                    isPresented = false
                } label: {
                    HStack {
                        Text("Apply Filters")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))

                        if tempFilters.activeFilterCount > 0 {
                            Text("(\(tempFilters.activeFilterCount))")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                        }
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPrimaryColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.appBackground)
            }
        }
        .onAppear {
            tempFilters = filters
        }
    }

    @ViewBuilder
    private func filterSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appPrimaryColor)

                Text(title)
                    .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
                    .foregroundStyle(Color.textPrimary)
            }

            content()
        }
    }
}
