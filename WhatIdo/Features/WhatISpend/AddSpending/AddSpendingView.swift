//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import Combine
import SwiftUI

struct AddSpendingView: View {
  @ObservedObject var viewModel: AddSpendingViewModel
  var selectedProject: ProjectDto?
  @Environment(\.dismiss) var dismiss
  var onSpendingAdded: (SpendingDto?) -> ()
  @ObservedObject var currencyManager = CurrencyManager.shared
  @State private var date = Date()
  @State private var calendarId: UUID = UUID()
  @State private var showNoteField: Bool = false
  @FocusState private var isAmountFocused: Bool

  var body: some View {
    VStack(spacing: 0) {
      // Amount Section
      amountSection
        .padding(.top, 16)

      // Note field (collapsible)
      noteSection
        .padding(.top, 16)

      // Context chips
      contextChips
        .padding(.top, 16)

      // Categories horizontal scroll
      categoriesSection
        .padding(.top, 20)

      // Save button
      saveButton
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
    .padding(.horizontal, 20)
    .background(Color.cardBackground)
    .onAppear {
      // Show note field if editing and has existing note
      if viewModel.spendingIdToEdit != nil && !viewModel.spendingItemTf.isEmpty {
        showNoteField = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        isAmountFocused = true
      }
    }
    .onChange(of: viewModel.dismissSheet) { shouldDismiss in
      guard shouldDismiss else { return }
      // Dismiss keyboard first
      UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
      )
      // Wait for keyboard to dismiss, then close sheet
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        onSpendingAdded(viewModel.spending)
      }
    }
    .onChange(of: date) { newVal in
      viewModel.dateTf = newVal.toDateReturnString()
      calendarId = UUID()
    }
    .contentShape(Rectangle())
    .onTapGesture {
      UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
      )
    }
    .alert(isPresented: $viewModel.showErrorAlert) {
      Alert(
        title: Text("Missing Info"),
        message: Text("Please enter amount and select a category."),
        dismissButton: .default(Text("OK"))
      )
    }
  }

  // MARK: - Amount Section
  private var amountSection: some View {
    VStack(spacing: 6) {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(currencyManager.currencyCode)
          .font(.customFont(family: .quicksand, name: .bold, size: .x24))
          .foregroundStyle(Color.appPrimaryColor)

        TextField("0", value: $viewModel.amountTf, format: .number)
          .keyboardType(.decimalPad)
          .font(.customFont(family: .inter, name: .bold, size: .x50))
          .foregroundStyle(Color.white)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: true, vertical: true)
          .tint(Color.appPrimaryColor)
          .focused($isAmountFocused)
          .onChange(of: viewModel.amountTf) { newValue in
            if newValue > 999_999_9 { viewModel.amountTf = 999_999_9 }
            if newValue < 0 { viewModel.amountTf = 0 }
          }
      }
    }
  }

  // MARK: - Note Section (Collapsible)
  private var noteSection: some View {
    Group {
      if showNoteField {
        HStack(spacing: 10) {
          AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "What's this for?", maxLength: 40)
            .frame(height: 46)

          Button {
            withAnimation { showNoteField = false }
            viewModel.spendingItemTf = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 22))
              .foregroundStyle(Color.gray)
          }
        }
      } else {
        Button {
          withAnimation { showNoteField = true }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: "square.and.pencil")
              .font(.system(size: 14))
            Text("Add note")
              .font(.customFont(family: .quicksand, name: .medium, size: .x14))
          }
          .foregroundStyle(Color.gray)
        }
      }
    }
  }

  // MARK: - Context Chips
  private var contextChips: some View {
    let month = viewModel.currentMonthInDateFormat ?? Date()
    return ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        // Date chip
        HStack(spacing: 6) {
          Image(systemName: "calendar")
            .font(.system(size: 14))
            .foregroundStyle(Color.appPrimaryColor)
          Text(viewModel.dateTf.isEmpty ? "Today" : viewModel.dateTf)
            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.1)))
        .overlay {
          DatePicker(
            selection: $date,
            in: month...(month.getMonthName() == Date().getMonthName() ? Date() : month.lastDateOfMonth() ?? Date()),
            displayedComponents: .date
          ) {}
            .labelsHidden()
            .opacity(0.011)
            .id(calendarId)
        }

        // Funding source chip
        Menu {
          ForEach(viewModel.fundingSources.compactMap { $0.rawValue }, id: \.self) { source in
            Button(source) { viewModel.selectedFundingSource = source }
          }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: "creditcard.fill")
              .font(.system(size: 14))
              .foregroundStyle(Color.appPrimaryColor)
            Text(viewModel.selectedFundingSource)
              .font(.customFont(family: .quicksand, name: .medium, size: .x14))
              .foregroundStyle(.white)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Capsule().fill(Color.white.opacity(0.1)))
        }

        // Project chip
        Menu {
          Button("None") { viewModel.selectedProject = nil }
          if let projects = viewModel.projects {
            ForEach(projects, id: \.id) { project in
              Button { viewModel.selectedProject = project } label: {
                Label(project.name, systemImage: project.icon)
              }
            }
          }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: viewModel.selectedProject?.icon ?? "folder.fill")
              .font(.system(size: 14))
              .foregroundStyle(Color.appPrimaryColor)
            Text(viewModel.selectedProject?.name ?? "Project")
              .font(.customFont(family: .quicksand, name: .medium, size: .x14))
              .foregroundStyle(viewModel.selectedProject == nil ? .gray : .white)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            Capsule().fill(
              viewModel.selectedProject == nil
              ? Color.white.opacity(0.05)
              : Color.appPrimaryColor.opacity(0.2)
            )
          )
        }
      }
    }
  }

  // MARK: - Categories Section (Icon + Label)
  private var categoriesSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHGrid(rows: [GridItem(.fixed(72)), GridItem(.fixed(72))], spacing: 10) {
        ForEach(viewModel.spendingTypes, id: \.id) { category in
          categoryItem(category)
        }
      }
      .padding(.vertical, 4)
    }
  }

  private func categoryItem(_ category: SpendingType) -> some View {
    let isSelected = viewModel.selectedType?.id == category.id
    return Button {
      withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
        viewModel.selectedType = category
      }
    } label: {
      VStack(spacing: 6) {
        ZStack {
          Circle()
            .fill(isSelected ? Color.appPrimaryColor : Color.white.opacity(0.08))
            .frame(width: 44, height: 44)
            .overlay(
              Circle()
                .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
            )

          Image(systemName: getIcon(for: category.name ?? ""))
            .font(.system(size: 18))
            .foregroundStyle(isSelected ? Color.black : Color.white)
        }

        Text(getShortName(for: category.name ?? ""))
          .font(.customFont(family: .quicksand, name: .medium, size: .x10))
          .foregroundStyle(isSelected ? Color.appPrimaryColor : Color.gray)
          .lineLimit(1)
      }
      .frame(width: 56)
    }
  }

  // MARK: - Short Name Helper
  private func getShortName(for name: String) -> String {
    switch name {
    case "Dining Out": return "Dining"
    case "Public Transit / Taxi": return "Transit"
    case "Utility Bills": return "Bills"
    case "Doctor & Checkups": return "Doctor"
    case "Pharmacy / Meds": return "Meds"
    case "Loan Repayment": return "Loan"
    case "Emergency Fund": return "Savings"
    case "Movies & Outings": return "Movies"
    case "Course & Books": return "Books"
    case "Salon & Grooming": return "Salon"
    case "Clothing & Tailor": return "Clothes"
    case "Electronics & Gadgets": return "Tech"
    case "Household Items": return "Home"
    case "Gifts / Donations": return "Gifts"
    case "Family Support": return "Family"
    case "Subscriptions": return "Subs"
    case "Maintenance": return "Repairs"
    default: return name
    }
  }

  // MARK: - Save Button
  private var saveButton: some View {
    Button {
      viewModel.saveSpending()
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.appPrimaryColor)

        if viewModel.isDataUploading {
          ProgressView()
            .tint(.black)
        } else {
          Text(viewModel.spendingIdToEdit == nil ? "Save" : "Update")
            .font(.customFont(name: .bold, size: .x18))
            .foregroundColor(.black)
        }
      }
      .frame(height: 55)
    }
    .disabled(viewModel.isDataUploading)
  }

  // MARK: - Icon Helper
  private func getIcon(for name: String) -> String {
    switch name.lowercased() {
    case "rent", "housing": return "house.fill"
    case "utility bills", "bills", "utility bill", "maintenance": return "bolt.fill"
    case "fuel", "petrol": return "fuelpump.fill"
    case "public transit / taxi", "travel", "transport": return "car.fill"
    case "groceries": return "cart.fill"
    case "dining out", "food", "dining": return "fork.knife"
    case "doctor & checkups", "health": return "stethoscope"
    case "pharmacy / meds", "medicine": return "pills.fill"
    case "loan repayment", "debt": return "banknote.fill"
    case "emergency fund", "savings": return "lock.shield.fill"
    case "subscriptions", "subscription": return "repeat.circle.fill"
    case "movies & outings", "entertainment": return "popcorn.fill"
    case "course & books", "education": return "book.closed.fill"
    case "salon & grooming", "grooming": return "scissors"
    case "clothing & tailor", "shopping": return "tshirt.fill"
    case "electronics & gadgets": return "laptopcomputer"
    case "household items": return "lamp.floor.fill"
    case "gifts / donations": return "gift.fill"
    case "family support", "allowance": return "figure.2.and.child.holdinghands"
    default: return "tag.fill"
    }
  }
}

#Preview {
  AddSpendingView(
    viewModel: AddSpendingViewModel(eventBus: PassthroughSubject<AppGlobalEvent, Never>()),
    selectedProject: nil,
    onSpendingAdded: { _ in }
  )
}
