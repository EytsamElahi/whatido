//
//  MonthYearPicker.swift
//  WhatIdo
//
//  Created by Eytsam Elahi on 15/01/2026.
//

import SwiftUI

struct MonthYearPicker: View {
    @Binding var date: Date
    var onSelection: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var year: Int
    private let months = Calendar.current.shortMonthSymbols // ["Jan", "Feb", ...]
    private let calendar = Calendar.current

    init(date: Binding<Date>, onSelection: @escaping () -> Void) {
        self._date = date
        self.onSelection = onSelection
        self._year = State(initialValue: Calendar.current.component(.year, from: date.wrappedValue))
    }

    var body: some View {
        ZStack {
            // 1. Force Background (Safety Net)
            Color.cardBackground.ignoresSafeArea() // Matches your app theme
            
            VStack(spacing: 25) {
                // 2. Year Selector (Polished)
                HStack(spacing: 20) {
                    Button {
                        withAnimation(.snappy) { year -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle()) // Make touch area bigger
                    }

                    Text(String(format: "%d", year)) // Removes comma (2,025 -> 2025)
                        .font(.customFont(family: .quicksand, name: .bold, size: .x24))
                        .foregroundStyle(.white)
                        .frame(minWidth: 80)

                    Button {
                        withAnimation(.snappy) { year += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.top, 10)

                // 3. Month Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(months.indices, id: \.self) { index in
                        let isSelected = isMonthSelected(monthIndex: index)
                        
                        Button {
                            selectMonth(index)
                        } label: {
                            Text(months[index])
                                .font(.customFont(family: .inter, name: .semiBold, size: .x16))
                                .foregroundStyle(isSelected ? Color.black : Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14) // Taller buttons look more modern
                                .background {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.appPrimaryColor) // Teal
                                            // Optional: Add a subtle glow for selected item
                                           // .shadow(color: Color.appPrimaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                                    } else {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(white: 0.15)) // Dark Gray
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
    }

    private func isMonthSelected(monthIndex: Int) -> Bool {
        let currentMonth = calendar.component(.month, from: date) - 1
        let currentYear = calendar.component(.year, from: date)
        return currentMonth == monthIndex && currentYear == year
    }

    private func selectMonth(_ index: Int) {
        var components = DateComponents()
        components.year = year
        components.month = index + 1
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            date = newDate
            
            // Haptic Feedback for "Click" feel
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            onSelection()
            dismiss()
        }
    }
}
