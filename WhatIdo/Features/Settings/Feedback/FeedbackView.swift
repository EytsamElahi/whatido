//
//  FeedbackView.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI

struct FeedbackView: View {
  @StateObject var viewModel: FeedbackViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack {
      Color.appBackground.ignoresSafeArea()

      VStack(spacing: 0) {
        headerView
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {
            feedbackTextSection
            ratingSection
            categorySection
            Spacer(minLength: 20)
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
        }
        submitButton
      }
    }
    .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
      if shouldDismiss {
        dismiss()
      }
    }
  }

  // MARK: - Header
  private var headerView: some View {
    HStack {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.white)
          .frame(width: 32, height: 32)
          .background(Color.white.opacity(0.1))
          .clipShape(Circle())
      }

      Spacer()

      Text("Beta Feedback")
        .font(.customFont(family: .quicksand, name: .bold, size: .x18))
        .foregroundStyle(.white)

      Spacer()

      Color.clear.frame(width: 32, height: 32)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
  }

  // MARK: - Feedback Text Section
  private var feedbackTextSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("What do you think about Yaru?")
        .font(.customFont(family: .quicksand, name: .bold, size: .x16))
        .foregroundStyle(.white)

      FeedbackTextEditor(text: $viewModel.feedbackText)
        .frame(height: 120)

      if !viewModel.feedbackText.isEmpty &&
         viewModel.feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).count < 10 {
        Text("Please enter at least 10 characters")
          .font(.customFont(family: .quicksand, name: .medium, size: .x12))
          .foregroundStyle(.red.opacity(0.8))
      }
    }
  }

  // MARK: - Rating Section
  private var ratingSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("How would you rate your experience?")
        .font(.customFont(family: .quicksand, name: .bold, size: .x16))
        .foregroundStyle(.white)

      StarRatingView(rating: $viewModel.rating)
    }
  }

  // MARK: - Category Section
  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Category")
        .font(.customFont(family: .quicksand, name: .bold, size: .x16))
        .foregroundStyle(.white)

      FeedbackCategoryPicker(selectedCategory: $viewModel.selectedCategory)
        .frame(height: 50)
    }
  }

  // MARK: - Submit Button
  private var submitButton: some View {
    AppPrimaryButton(
      title: "Submit Feedback",
      disable: .constant(!viewModel.isValid),
      isLoading: $viewModel.isLoading
    ) {
      viewModel.submitFeedback()
    }
    .padding(.vertical, 20)
  }
}

// MARK: - Star Rating View
struct StarRatingView: View {
  @Binding var rating: Int
  let maxRating: Int = 5

  var body: some View {
    HStack(spacing: 12) {
      ForEach(1...maxRating, id: \.self) { index in
        Button {
          rating = index
        } label: {
          Image(systemName: index <= rating ? "star.fill" : "star")
            .font(.system(size: 32))
            .foregroundStyle(index <= rating ? Color.yellow : Color.white.opacity(0.3))
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.vertical, 8)
  }
}

// MARK: - Feedback Text Editor
struct FeedbackTextEditor: View {
  @Binding var text: String

  var body: some View {
    ZStack(alignment: .topLeading) {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white.opacity(0.08))

      if text.isEmpty {
        Text("Share your thoughts, suggestions, or report issues...")
          .font(.customFont(name: .regular, size: .x14))
          .foregroundColor(Color.white.opacity(0.3))
          .padding(.horizontal, 15)
          .padding(.top, 12)
          .allowsHitTesting(false)
      }

      TextEditor(text: $text)
        .font(.customFont(name: .medium, size: .x14))
        .foregroundColor(.white)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .tint(Color.appPrimaryColor)
    }
  }
}

// MARK: - Category Picker
struct FeedbackCategoryPicker: View {
  @Binding var selectedCategory: FeedbackCategory

  var body: some View {
    Menu {
      ForEach(FeedbackCategory.allCases, id: \.self) { category in
        Button {
          selectedCategory = category
        } label: {
          HStack {
            Text(category.displayName)
            if selectedCategory == category {
              Spacer()
              Image(systemName: "checkmark")
            }
          }
        }
      }
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.white.opacity(0.08))

        HStack {
          Text(selectedCategory.displayName)
            .font(.customFont(name: .medium, size: .x14))
            .foregroundColor(.white)

          Spacer()

          Image(systemName: "chevron.down")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.appPrimaryColor)
        }
        .padding(.horizontal, 15)
      }
    }
  }
}

#Preview {
  FeedbackView(viewModel: FeedbackViewModel(feedbackService: FeedbackService()))
}
