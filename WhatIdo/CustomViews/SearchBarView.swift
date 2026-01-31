//
//  SearchBarView.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI

struct SearchBarView: View {
  @Binding var searchText: String
  var isFocused: FocusState<Bool>.Binding

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(Color.gray)

      TextField("Search transactions...", text: $searchText)
        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
        .foregroundStyle(Color.textPrimary)
        .focused(isFocused)
        .tint(Color.textPrimary)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 16))
            .foregroundStyle(Color.gray)
        }
      }
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(Color.cardBackground)
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(isFocused.wrappedValue ? Color.appPrimaryColor.opacity(0.5) : Color.clear, lineWidth: 1)
    )
  }
}

struct SearchBarView_Previews: PreviewProvider {
  struct PreviewWrapper: View {
    @State private var searchText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
      ZStack {
        Color.appBackground.ignoresSafeArea()
        SearchBarView(searchText: $searchText, isFocused: $isFocused)
          .padding()
      }
    }
  }

  static var previews: some View {
    PreviewWrapper()
  }
}
