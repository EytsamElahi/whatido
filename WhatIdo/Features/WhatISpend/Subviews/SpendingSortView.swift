//
//  SpendingSortView.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI

// MARK: - Sort Option Model
enum SortField: String, CaseIterable, Identifiable {
  case date = "Date"
  case amount = "Amount"
  case category = "Category"
  case name = "Name"

  var id: String { rawValue }

  var icon: String {
    switch self {
    case .date: return "calendar"
    case .amount: return "dollarsign.circle"
    case .category: return "tag"
    case .name: return "textformat"
    }
  }
}

enum SortDirection: String, CaseIterable {
  case ascending
  case descending

  var icon: String {
    switch self {
    case .ascending: return "arrow.up"
    case .descending: return "arrow.down"
    }
  }

  mutating func toggle() {
    self = self == .ascending ? .descending : .ascending
  }
}

struct SpendingSortOption: Equatable {
  var field: SortField
  var direction: SortDirection

  var displayName: String {
    switch field {
    case .date:
      return direction == .descending ? "Newest First" : "Oldest First"
    case .amount:
      return direction == .descending ? "Highest First" : "Lowest First"
    case .category:
      return direction == .ascending ? "A → Z" : "Z → A"
    case .name:
      return direction == .ascending ? "A → Z" : "Z → A"
    }
  }

  static var `default`: SpendingSortOption {
    SpendingSortOption(field: .date, direction: .descending)
  }
}

// MARK: - Sort Menu View
struct SortMenuView: View {
  @Binding var currentSort: SpendingSortOption
  let onSortChanged: () -> Void

  var body: some View {
    Menu {
      ForEach(SortField.allCases) { field in
        Button {
          if currentSort.field == field {
            // Toggle direction if same field
            currentSort.direction.toggle()
          } else {
            // Set new field with default direction
            currentSort.field = field
            currentSort.direction = field == .date || field == .amount ? .descending : .ascending
          }
          onSortChanged()
        } label: {
          HStack {
            Label(field.rawValue, systemImage: field.icon)

            Spacer()

            if currentSort.field == field {
              Image(systemName: currentSort.direction.icon)
                .foregroundStyle(Color.appPrimaryColor)
            }
          }
        }
      }
    } label: {
      HStack(spacing: 4) {
        Image(systemName: "arrow.up.arrow.down")
          .font(.system(size: 18))

        if currentSort.field != .date || currentSort.direction != .descending {
          // Show indicator when not default sort
          Circle()
            .fill(Color.appPrimaryColor)
            .frame(width: 6, height: 6)
        }
      }
      .foregroundStyle(Color.gray)
    }
  }
}

// MARK: - Sort Sheet View (Alternative Full Sheet)
struct SpendingSortSheet: View {
  @Binding var currentSort: SpendingSortOption
  @Binding var isPresented: Bool
  let onApply: () -> Void

  @State private var tempSort: SpendingSortOption = .default

  var body: some View {
    NavigationView {
      ZStack {
        Color.appBackground.ignoresSafeArea()

        VStack(alignment: .leading, spacing: 20) {
          ForEach(SortField.allCases) { field in
            sortOptionRow(for: field)
          }

          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
      }
      .navigationTitle("Sort By")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            isPresented = false
          }
          .foregroundStyle(Color.gray)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Apply") {
            currentSort = tempSort
            onApply()
            isPresented = false
          }
          .foregroundStyle(Color.appPrimaryColor)
          .fontWeight(.semibold)
        }
      }
    }
    .onAppear {
      tempSort = currentSort
    }
  }

  @ViewBuilder
  private func sortOptionRow(for field: SortField) -> some View {
    let isSelected = tempSort.field == field

    Button {
      if tempSort.field == field {
        tempSort.direction.toggle()
      } else {
        tempSort.field = field
        tempSort.direction = field == .date || field == .amount ? .descending : .ascending
      }
    } label: {
      HStack(spacing: 14) {
        // Icon
        ZStack {
          Circle()
            .fill(isSelected ? Color.appPrimaryColor.opacity(0.15) : Color.cardBackground)
            .frame(width: 44, height: 44)

          Image(systemName: field.icon)
            .font(.system(size: 18))
            .foregroundStyle(isSelected ? Color.appPrimaryColor : Color.gray)
        }

        // Field Name
        VStack(alignment: .leading, spacing: 2) {
          Text(field.rawValue)
            .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
            .foregroundStyle(Color.textPrimary)

          if isSelected {
            Text(tempSort.displayName)
              .font(.customFont(family: .quicksand, name: .medium, size: .x12))
              .foregroundStyle(Color.appPrimaryColor)
          }
        }

        Spacer()

        // Direction indicator
        if isSelected {
          HStack(spacing: 8) {
            // Direction toggle buttons
            directionButton(direction: .ascending, field: field)
            directionButton(direction: .descending, field: field)
          }
        } else {
          Image(systemName: "circle")
            .font(.system(size: 22))
            .foregroundStyle(Color.gray.opacity(0.3))
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .background(isSelected ? Color.appPrimaryColor.opacity(0.08) : Color.clear)
      .cornerRadius(12)
    }
  }

  @ViewBuilder
  private func directionButton(direction: SortDirection, field: SortField) -> some View {
    let isActive = tempSort.direction == direction

    Button {
      tempSort.direction = direction
    } label: {
      Image(systemName: direction.icon)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(isActive ? Color.white : Color.gray)
        .frame(width: 32, height: 32)
        .background(isActive ? Color.appPrimaryColor : Color.cardBackground)
        .cornerRadius(8)
    }
  }
}

// MARK: - Sorting Extension for SpendingDto Array
extension Array where Element == SpendingDto {
  func sorted(by option: SpendingSortOption) -> [SpendingDto] {
    switch option.field {
    case .date:
      return self.sorted { s1, s2 in
        option.direction == .descending ? s1.date > s2.date : s1.date < s2.date
      }

    case .amount:
      return self.sorted { s1, s2 in
        option.direction == .descending ? s1.amount > s2.amount : s1.amount < s2.amount
      }

    case .category:
      return self.sorted { s1, s2 in
        option.direction == .ascending ?
          s1.type.lowercased() < s2.type.lowercased() :
          s1.type.lowercased() > s2.type.lowercased()
      }

    case .name:
      return self.sorted { s1, s2 in
        option.direction == .ascending ?
          s1.name.lowercased() < s2.name.lowercased() :
          s1.name.lowercased() > s2.name.lowercased()
      }
    }
  }
}
