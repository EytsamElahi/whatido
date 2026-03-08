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
  var onDismiss: (() -> Void)?

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(Color.gray)

      TextField("", text: $searchText, prompt: Text("Search transactions...").foregroundColor(Color(white: 0.6)))
        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
        .foregroundStyle(Color.textPrimary)
        .focused(isFocused)
        .tint(Color.textPrimary)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)

      // Clear text button
      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 16))
            .foregroundStyle(Color.gray)
        }
      }

      // Dismiss search bar button
      if let onDismiss = onDismiss {
        Button {
          searchText = ""
          isFocused.wrappedValue = false
          onDismiss()
        } label: {
          Text("Cancel")
            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
            .foregroundStyle(Color.appPrimaryColor)
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
