//
//  SpendingFilterView.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI

// MARK: - Filter Models
struct SpendingFilters: Equatable {
  var dateRange: DateRangeFilter = .all
  var amountRange: AmountRangeFilter = .all
  var categories: Set<String> = []
  // var fundSources: Set<FundSource> = [] // disabled — source field removed from UI
  var hasProject: ProjectFilter = .all

  var isActive: Bool {
    dateRange != .all ||
    amountRange != .all ||
    !categories.isEmpty ||
    // !fundSources.isEmpty || // disabled
    hasProject != .all
  }

  var activeFilterCount: Int {
    var count = 0
    if dateRange != .all { count += 1 }
    if amountRange != .all { count += 1 }
    if !categories.isEmpty { count += 1 }
    // if !fundSources.isEmpty { count += 1 } // disabled
    if hasProject != .all { count += 1 }
    return count
  }

  mutating func reset() {
    dateRange = .all
    amountRange = .all
    categories = []
    // fundSources = [] // disabled
    hasProject = .all
  }
}

enum DateRangeFilter: String, CaseIterable, Identifiable {
  case all = "All"
  case today = "Today"
  case last7Days = "Last 7 Days"
  case last14Days = "Last 14 Days"
  case thisWeek = "This Week"

  var id: String { rawValue }
}

enum AmountRangeFilter: String, CaseIterable, Identifiable {
  case all = "All"
  case under50 = "Under 50"
  case from50to100 = "50 - 100"
  case from100to500 = "100 - 500"
  case from500to1000 = "500 - 1000"
  case over1000 = "Over 1000"

  var id: String { rawValue }

  func matches(amount: Double) -> Bool {
    switch self {
    case .all: return true
    case .under50: return amount < 50
    case .from50to100: return amount >= 50 && amount < 100
    case .from100to500: return amount >= 100 && amount < 500
    case .from500to1000: return amount >= 500 && amount < 1000
    case .over1000: return amount >= 1000
    }
  }
}

enum ProjectFilter: String, CaseIterable, Identifiable {
  case all = "All"
  case withProject = "Linked to Project"
  case withoutProject = "No Project"

  var id: String { rawValue }
}

// MARK: - Filter Sheet View
struct SpendingFilterView: View {
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
            // MARK: - Date Range
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

            // MARK: - Amount Range
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

            // MARK: - Categories
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

            // MARK: - Fund Source (disabled — source field removed from UI)
//            filterSection(title: "Payment Method", icon: "creditcard") {
//              FlowLayout(spacing: 8) {
//                ForEach(FundSource.allCases, id: \.self) { source in
//                  FilterChip(
//                    title: source.rawValue,
//                    isSelected: tempFilters.fundSources.contains(source)
//                  ) {
//                    if tempFilters.fundSources.contains(source) {
//                      tempFilters.fundSources.remove(source)
//                    } else {
//                      tempFilters.fundSources.insert(source)
//                    }
//                  }
//                }
//              }
//            }

            // MARK: - Project Filter
            filterSection(title: "Project", icon: "folder") {
              FlowLayout(spacing: 8) {
                ForEach(ProjectFilter.allCases) { option in
                  FilterChip(
                    title: option.rawValue,
                    isSelected: tempFilters.hasProject == option
                  ) {
                    tempFilters.hasProject = option
                  }
                }
              }
            }

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
        applyButton
      }
    }
    .onAppear {
      tempFilters = filters
    }
  }

  // MARK: - Section Builder
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

  // MARK: - Apply Button
  private var applyButton: some View {
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

// MARK: - Filter Chip
struct FilterChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.customFont(family: .quicksand, name: isSelected ? .semiBold : .medium, size: .x14))
        .foregroundStyle(isSelected ? Color.white : Color.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? Color.appPrimaryColor : Color.cardBackground)
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
  }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)
    return result.size
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)

    for (index, frame) in result.frames.enumerated() {
      subviews[index].place(
        at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
        proposal: ProposedViewSize(frame.size)
      )
    }
  }

  private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
    let maxWidth = proposal.width ?? .infinity
    var currentX: CGFloat = 0
    var currentY: CGFloat = 0
    var lineHeight: CGFloat = 0
    var frames: [CGRect] = []

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)

      if currentX + size.width > maxWidth && currentX > 0 {
        currentX = 0
        currentY += lineHeight + spacing
        lineHeight = 0
      }

      frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
      lineHeight = max(lineHeight, size.height)
      currentX += size.width + spacing
    }

    let totalHeight = currentY + lineHeight
    return (CGSize(width: maxWidth, height: totalHeight), frames)
  }
}
