//
//  AddIncomeTransactionSheet.swift
//  WhatIdo
//

import SwiftUI

struct AddIncomeTransactionSheet: View {
  @ObservedObject var viewModel: AccountsViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var amountString: String = ""
  @State private var selectedAccountId: String = ""
  @State private var selectedSourceId: String = ""
  @State private var selectedSourceName: String = ""
  @State private var receivedAt: Date = Date()
  @State private var note: String = ""

  private var assetAccounts: [AccountDto] {
    viewModel.accounts.filter { !$0.type.isLiability }
  }

  private var isValid: Bool {
    guard let amount = Double(amountString), amount > 0 else { return false }
    return !selectedAccountId.isEmpty && !selectedSourceId.isEmpty
  }

  var body: some View {
    ZStack {
      Color.cardBackground.ignoresSafeArea()
      VStack(spacing: 12) {
        Capsule()
          .frame(width: 40, height: 5)
          .foregroundStyle(Color.gray.opacity(0.3))
          .padding(.top, 6)

        Text("Record Income")
          .font(.customFont(family: .quicksand, name: .bold, size: .x20))
          .foregroundStyle(Color.white)

        amountField
        accountPicker
        sourcePicker
        datePicker
        noteField
        saveButton
      }
      .padding(.horizontal)
      .padding(.bottom, 8)
    }
    .onAppear {
      if let first = assetAccounts.first { selectedAccountId = first.id }
      if let first = viewModel.incomeSources.first {
        selectedSourceId = first.id
        selectedSourceName = first.name
      }
    }
    .presentationDetents([.height(490)])
    .presentationDragIndicator(.hidden)
    .hideKeyboardOnTapAround()
  }

  private var amountField: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Amount")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      AppTextfield(inputText: $amountString, placeHolder: "0.00", keyboardType: .decimalPad)
        .frame(height: 48)
    }
  }

  private var accountPicker: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("To Account")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(assetAccounts, id: \.id) { acc in
            Button {
              withAnimation { selectedAccountId = acc.id }
            } label: {
              CapsuleView(name: acc.name, isSelected: acc.id == selectedAccountId)
            }
          }
        }
      }
    }
  }

  private var sourcePicker: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Income Source")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(viewModel.incomeSources, id: \.id) { source in
            Button {
              withAnimation {
                selectedSourceId = source.id
                selectedSourceName = source.name
              }
            } label: {
              CapsuleView(name: source.name, isSelected: source.id == selectedSourceId)
            }
          }
        }
      }
    }
  }

  private var datePicker: some View {
    HStack {
      Text("Date")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      Spacer()
      DatePicker("", selection: $receivedAt, in: ...Date(), displayedComponents: .date)
        .datePickerStyle(.compact)
        .labelsHidden()
        .tint(Color.appPrimaryColor)
        .colorScheme(.dark)
    }
  }

  private var noteField: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Note (optional)")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      AppTextfield(inputText: $note, placeHolder: "Add a note...", maxLength: 100)
        .frame(height: 48)
    }
  }

  private var saveButton: some View {
    AppPrimaryButton(
      title: "Save",
      disable: .constant(!isValid),
      isLoading: $viewModel.isLoading
    ) {
      hideKeyboard()
      guard let amount = Double(amountString), amount > 0 else { return }
      guard let currency = AppData.prefCurrency?.code else { return }
      viewModel.addIncomeTransaction(
        accountId: selectedAccountId,
        sourceId: selectedSourceId,
        sourceName: selectedSourceName,
        amount: amount,
        currency: currency,
        note: note.isEmpty ? nil : note,
        receivedAt: receivedAt
      )
    }
    .disabled(viewModel.isLoading)
  }
}
