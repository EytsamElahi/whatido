//
//  SpendingCalendarSplitView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//


import SwiftUI

struct MonthItem: Hashable, Identifiable {
    let id = UUID()
    let month: String
    let year: Int
}
struct SpendingCalendarSplitView: View {
    @EnvironmentObject var viewModel: SpendingsViewModel
    @State var monthData: [Int: [MonthItem]] = [:]

    var body: some View {
        VStack {
            if viewModel.fetchingAllSpendings {
                CircularLoadingIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                if let monthData = viewModel.allSpendingsMonthYear {
                    List {
                        ForEach(monthData.keys.sorted(by: >), id: \.self) { year in
                            Section(header:
                                        Text("\(year)")
                                .font(.title) // 👈 Large font
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .padding(.vertical, 4)
                            ) {
                                ForEach(monthData[year] ?? []) { month in
                                    Text(month.month)
                                }
                            }
                        }
                    }
                }
            }
        }.navigationBarBackButtonHidden(true)
        .onAppear {
            guard !viewModel.fetchingAllSpendings else { return }
            viewModel.fetchallSpendings()
        }
    }
}

#Preview {
    SpendingCalendarSplitView()
}
