//
//  AnalyticsView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/12/2025.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel
    @EnvironmentObject var navigation: NavigationManager
    @State private var showDatePicker = false
    // Animation Namespace
    @Namespace private var animation

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - 1. Custom Header
                AppHeaderView(title: viewModel.isCustomMode ? "History" : "Analytics", trailingButtonIcon: "calendar", backAction: {
                    if viewModel.isCustomMode {
                        // If in history mode, back button returns to normal tabs
                        withAnimation { viewModel.isCustomMode = false }
                        viewModel.spendings = []
                        viewModel.chartData = []
                        viewModel.fetchAnalytics()
                    } else {
                        navigation.pop()
                    }
                }, trailingButtonAction: {
                    showDatePicker = true
                })

                ScrollView {
                    VStack(spacing: 25) {
                        
                        // 2. The Segment Control (Extracted)
                        if !viewModel.isCustomMode {
                            segmentControlView
                        } else {
                            // Show which month we are viewing
                            Text(viewModel.customDate.formatted(.dateTime.month(.wide).year()))
                                .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                                .foregroundStyle(.white)
                                .padding(.top, 20)
                        }
                        
                        // 3. Total Spent
                        totalSpentView
                        
                        // 4. The Chart (Extracted)
                        chartView
                        
                        // 5. The List (Extracted)
                        breakdownListView
                        
                    } // End Main VStack
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchAnalytics()
        }
        .sheet(isPresented: $showDatePicker) {
            MonthYearPicker(date: $viewModel.customDate) {
                // This runs when a month is clicked
                viewModel.isCustomMode = true
                
                viewModel.chartData = []
                viewModel.spendings = []
                
                viewModel.fetchAnalytics()
                showDatePicker = false
            }
            .presentationDetents([.height(350)]) // Slightly taller for breathing room
                .presentationCornerRadius(30)      // Nice rounded top corners
                .presentationDragIndicator(.visible) // Shows the little gray handle
                .presentationBackground(Color.cardBackground) // Or Color.appBackground
        }
    }
}

// MARK: - Subviews to fix Compiler Error
extension AnalyticsView {
    
    // 1️⃣ Segment Control View
    var segmentControlView: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.snappy) {
                        viewModel.selectedRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.customFont(family: .inter, name: .medium, size: .x14))
                        .foregroundStyle(viewModel.selectedRange == range ? Color.black : Color.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if viewModel.selectedRange == range {
                                Capsule()
                                    .fill(Color.appPrimaryColor)
                                // .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                            }
                        }
                }
            }
        }
        .padding(5)
        .background(Color(white: 0.15))
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.top, 15)
        .onChange(of: viewModel.selectedRange) { _ in
            viewModel.fetchAnalytics()
        }
    }
    
    // 2️⃣ Total Spent Text
    var totalSpentView: some View {
        VStack(spacing: 5) {
            Text("Total Spent")
                .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                .foregroundStyle(Color.gray)
            
            Text(viewModel.totalSpent.toCurrency)
                .font(.customFont(family: .quicksand, name: .bold, size: .x34))
                .foregroundStyle(Color.appPrimaryColor)
        }
        .padding(.top, 10)
    }
    
    // 3️⃣ Chart View
    var chartView: some View {
        Group {
            // Calculate Total locally to determine percentages
            let totalForChart = viewModel.chartData.reduce(0) { $0 + $1.totalAmount }
            
            // 🔥 FIX: Filter out slices smaller than 0.5%
            // These invisible slices cause the Geometry/CornerRadius crash.
            let cleanData = viewModel.chartData.filter { item in
                let isFinite = item.totalAmount.isFinite && item.totalAmount > 0
                if !isFinite { return false }
                
                // If total is 0, allow nothing.
                if totalForChart <= 0 { return false }
                
                // Calculate percentage
                let percentage = item.totalAmount / totalForChart
                
                // Only show if it's bigger than 0.5% (0.005)
                return percentage >= 0.005
            }
            
            if !cleanData.isEmpty {
//                Chart(cleanData) { item in
//                    SectorMark(
//                        angle: .value("Amount", item.totalAmount),
//                        innerRadius: .ratio(0.65),
//                        outerRadius: .ratio(1.0),
//                        // Only use inset if we have enough slices, otherwise 0
//                        angularInset: cleanData.count > 1 ? 2.0 : 0
//                    )
//                    // 🔥 OPTIONAL SAFETY: Reduce corner radius slightly
//                    .cornerRadius(4)
//                    .foregroundStyle(by: .value("Category", item.spendingName))
//                }
//                .frame(height: 280)
//                .padding(.horizontal, 40)
//                .chartLegend(.hidden)
//                .chartForegroundStyleScale(
//                    domain: cleanData.map { $0.spendingName },
//                    range: cleanData.map { $0.color }
//                )
//                .id(viewModel.selectedRange)
//                .animation(nil, value: viewModel.chartData)
                
            } else {
                // Empty State
                VStack(spacing: 15) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.gray.opacity(0.2))
                    Text("No expenses yet")
                        .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                        .foregroundStyle(.gray)
                }
                .frame(height: 250)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.chartData.isEmpty)
    }
    
    
    var breakdownListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Breakdown")
                .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                .foregroundStyle(.white)
                .padding(.horizontal)
            
            ForEach(viewModel.chartData) { data in
                // Use the new subview here
                AnalyticsCategoryCard(data: data, totalSpent: viewModel.totalSpent)
            }
        }
        .padding(.bottom, 40)
    }
}

struct AnalyticsCategoryCard: View {
    let data: SpendingTypeChartData
    let totalSpent: Double

    // Local state for expansion
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header (The Main Card)
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 15) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(data.color.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: data.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(data.color)
                    }

                    // Name
                    Text(data.spendingName)
                        .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
                        .foregroundStyle(.white)

                    Spacer()

                    // Amount & Percent
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(AppData.prefCurrency?.symbol ?? "$") \(String(format: "%.0f", data.totalAmount))")
                            .font(.customFont(family: .inter, name: .bold, size: .x16))
                            .foregroundStyle(.white)

                        let safeTotal = totalSpent > 0 ? totalSpent : 1
                        let percent = (data.totalAmount / safeTotal) * 100

                        HStack(spacing: 4) {
                            Text("\(String(format: "%.1f", percent))%")
                            // Chevron indicator
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                        .font(.customFont(family: .inter, name: .medium, size: .x12))
                        .foregroundStyle(.gray)
                    }
                }
                .padding(12)
                .background(Color(white: 0.1)) // Card Background
            }

            // MARK: - Expanded Details
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)

                    ForEach(data.transactions, id: \.self) { transaction in
                        HStack {
                            // Date
                            Text(transaction.date.formatted(.dateTime.day().month()))
                                .font(.customFont(family: .inter, name: .medium, size: .x12))
                                .foregroundStyle(.gray)
                                .frame(width: 50, alignment: .leading)

                            // Note/Title (Assuming SpendingDto has a 'note' or 'title')
                            Text(transaction.name.isEmpty ? "No description" : transaction.name)
                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(1)

                            Spacer()

                            // Amount
                            Text("\(AppData.prefCurrency?.symbol ?? "$")\(String(format: "%.0f", transaction.amount))")
                                .font(.customFont(family: .inter, name: .semiBold, size: .x14))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        // Separator between items (except last)
                        if transaction.id != data.transactions.last?.id {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                                .padding(.leading, 66) // Indent divider
                        }
                    }
                }
                .background(Color(white: 0.08)) // Slightly darker for inner list
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
