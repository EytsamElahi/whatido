//
//  AddSpendingRow.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//

import SwiftUI

struct AddSpendingRow: View {
  @EnvironmentObject var viewModel: SpendingsViewModel

  private var isNotDefaultSort: Bool {
    viewModel.sortOption.field != .date || viewModel.sortOption.direction != .descending
  }

  private var isSearchActive: Bool {
    !viewModel.searchText.isEmpty
  }

  private var activeToolsCount: Int {
    var count = 0
    if isSearchActive { count += 1 }
    if viewModel.filters.isActive { count += viewModel.filters.activeFilterCount }
    if isNotDefaultSort { count += 1 }
    return count
  }

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Transactions")
          .font(.customFont(family: .quicksand, name: .bold, size: .x20))
          .foregroundStyle(Color.textPrimary)

        Spacer()

        Button {
          viewModel.spendingToEdit = nil
          viewModel.showAddSheet.toggle()
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(Color.appPrimaryColor)
        }

        if viewModel.currentMonthSpendings?.isEmpty == false {
          Menu {
            Button {
              withAnimation(.easeOut(duration: 0.25)) {
                viewModel.showSearchBar.toggle()
                if !viewModel.showSearchBar { viewModel.searchText = "" }
              }
            } label: {
              Label(
                viewModel.showSearchBar
                  ? "Hide Search"
                  : (isSearchActive ? "Search (active)" : "Search"),
                systemImage: "magnifyingglass"
              )
            }

            Button {
              viewModel.showFilterSheet = true
            } label: {
              Label(
                viewModel.filters.isActive
                  ? "Filter (\(viewModel.filters.activeFilterCount))"
                  : "Filter",
                systemImage: "line.3.horizontal.decrease"
              )
            }

            Divider()

            Menu {
              ForEach(SortField.allCases) { field in
                Button {
                  withAnimation {
                    if viewModel.sortOption.field == field {
                      viewModel.sortOption.direction.toggle()
                    } else {
                      viewModel.sortOption = SpendingSortOption(field: field, direction: .descending)
                    }
                  }
                } label: {
                  HStack {
                    Text(field.rawValue)
                    if viewModel.sortOption.field == field {
                      Image(systemName: viewModel.sortOption.direction == .ascending
                            ? "chevron.up" : "chevron.down")
                    }
                  }
                }
              }
            } label: {
              Label(
                isNotDefaultSort ? "Sort: \(viewModel.sortOption.field.rawValue)" : "Sort",
                systemImage: "arrow.up.arrow.down"
              )
            }

            if activeToolsCount > 0 {
              Divider()
              Button(role: .destructive) {
                withAnimation(.easeOut(duration: 0.2)) {
                  viewModel.filters.reset()
                  viewModel.sortOption = .default
                  viewModel.searchText = ""
                  viewModel.showSearchBar = false
                }
              } label: {
                Label("Reset All", systemImage: "xmark.circle")
              }
            }
          } label: {
            ZStack(alignment: .topTrailing) {
              Image(systemName: "ellipsis.circle")
                .font(.system(size: 26))
                .foregroundStyle(activeToolsCount > 0 ? Color.appPrimaryColor : Color.gray)

              if activeToolsCount > 0 {
                Text("\(activeToolsCount)")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundStyle(Color.white)
                  .frame(width: 16, height: 16)
                  .background(Color.appPrimaryColor)
                  .clipShape(Circle())
                  .offset(x: 4, y: -4)
              }
            }
          }
        }
      }

      if viewModel.filters.isActive || isNotDefaultSort {
        HStack {
          if isNotDefaultSort {
            HStack(spacing: 4) {
              Image(systemName: viewModel.sortOption.field.icon)
                .font(.system(size: 10))
              Text(viewModel.sortOption.displayName)
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
            }
            .foregroundStyle(Color.appPrimaryColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.appPrimaryColor.opacity(0.15))
            .cornerRadius(12)
          }

          if viewModel.filters.isActive {
            Text("\(viewModel.filters.activeFilterCount) filter\(viewModel.filters.activeFilterCount > 1 ? "s" : "")")
              .font(.customFont(family: .quicksand, name: .medium, size: .x12))
              .foregroundStyle(Color.gray)
          }

          Spacer()

          Button {
            withAnimation(.easeOut(duration: 0.2)) {
              viewModel.filters.reset()
              viewModel.sortOption = .default
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
    .animation(.easeOut(duration: 0.2), value: viewModel.filters.isActive)
    .animation(.easeOut(duration: 0.2), value: viewModel.sortOption)
  }
}
