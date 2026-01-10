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

    // Animation Namespace
    @Namespace private var animation

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - 1. Custom Header
                AppHeaderView(title: "Analytics", backAction: {
                    navigation.pop()
                })

                ScrollView {
                    VStack(spacing: 25) {

                        // 2. The Segment Control (Extracted)
                        segmentControlView

                        // 3. Total Spent
                        totalSpentView

                        // 4. The Chart (Extracted)
                        chartView

                        // 5. The List (Extracted)
                        if !viewModel.chartData.isEmpty {
                            breakdownListView
                        }

                    } // End Main VStack
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchAnalytics()
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
                if !viewModel.chartData.isEmpty {
                    Chart(viewModel.chartData) { item in
                        SectorMark(
                            angle: .value("Amount", item.totalAmount),
                            innerRadius: .ratio(0.65),
                            outerRadius: .ratio(1.0),
                            angularInset: 2.0
                        )
                        .cornerRadius(6)
                        .foregroundStyle(by: .value("Category", item.spendingName))
                    }
                    .frame(height: 280)
                    .padding(.horizontal, 40)
                    .chartLegend(.hidden)
                    .chartForegroundStyleScale(
                        domain: viewModel.chartData.map { $0.spendingName },
                        range: viewModel.chartData.map { $0.color }
                    )
                    .animation(nil, value: viewModel.chartData)
                    .id(viewModel.selectedRange)

                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.gray.opacity(0.2))
                        Text("No expenses yet")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                            .foregroundStyle(.gray)
                    }
                    .frame(height: 250)
                    .transition(.opacity) // Fade effect for empty state
                }
            }
            // 🔥 Extra Safety: Pura Chart View smooth fade karega bajaye shrink hone k
            .animation(.easeInOut, value: viewModel.chartData.isEmpty)
        }

    // 4️⃣ Breakdown List View
    var breakdownListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Breakdown")
                .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                .foregroundStyle(.white)
                .padding(.horizontal)

            ForEach(viewModel.chartData) { data in
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

                    // Amount & Percentage Logic
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(AppData.prefCurrency?.symbol ?? "$") \(String(format: "%.0f", data.totalAmount))")
                            .font(.customFont(family: .inter, name: .bold, size: .x16))
                            .foregroundStyle(.white)

                        // 🔥 CRITICAL FIX: Safe Division Logic
                        // Agar TotalSpent 0 hai, to hum 1 use karenge taake crash na ho
                        let safeTotal = viewModel.totalSpent > 0 ? viewModel.totalSpent : 1
                        let percent = (data.totalAmount / safeTotal) * 100

                        Text("\(String(format: "%.1f", percent))%")
                            .font(.customFont(family: .inter, name: .medium, size: .x12))
                            .foregroundStyle(.gray)
                    }
                }
                .padding(12)
                .background(Color(white: 0.1))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 40)
    }
}
