//
//  AddTransferSheet.swift
//  WhatIdo
//

import SwiftUI

struct AddTransferSheet: View {
  @ObservedObject var viewModel: AccountsViewModel

  @State private var fromAccountId: String = ""
  @State private var toAccountId: String = ""
  @State private var amountString: String = ""
  @State private var includeFee: Bool = false
  @State private var feeString: String = ""
  @State private var note: String = ""

  private var assetAccounts: [AccountDto] {
    viewModel.accounts.filter { !$0.type.isLiability }
  }

  private var toAccounts: [AccountDto] {
    assetAccounts.filter { $0.id != fromAccountId }
  }

  private var isValid: Bool {
    guard let amount = Double(amountString), amount > 0 else { return false }
    return !fromAccountId.isEmpty && !toAccountId.isEmpty && fromAccountId != toAccountId
  }

  var body: some View {
    ZStack {
      Color.cardBackground.ignoresSafeArea()
      VStack(spacing: 12) {
        Capsule()
          .frame(width: 40, height: 5)
          .foregroundStyle(Color.gray.opacity(0.3))
          .padding(.top, 6)

        Text("Transfer Funds")
          .font(.customFont(family: .quicksand, name: .bold, size: .x20))
          .foregroundStyle(Color.white)

        fromPicker
        toPicker
        amountField
        feeSection
        noteField
        confirmButton
      }
      .padding(.horizontal)
      .padding(.bottom, 8)
    }
    .onAppear { setupDefaults() }
    .onChange(of: fromAccountId) { _ in
      if toAccountId == fromAccountId { toAccountId = "" }
    }
    .presentationDetents([.height(includeFee ? 530 : 480)])
    .presentationDragIndicator(.hidden)
    .hideKeyboardOnTapAround()
  }

  private var fromPicker: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("From Account")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(assetAccounts, id: \.id) { acc in
            Button {
              withAnimation { fromAccountId = acc.id }
            } label: {
              CapsuleView(name: acc.name, isSelected: acc.id == fromAccountId)
            }
          }
        }
      }
    }
  }

  private var toPicker: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("To Account")
        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
        .foregroundStyle(Color.white)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(toAccounts, id: \.id) { acc in
            Button {
              withAnimation { toAccountId = acc.id }
            } label: {
              CapsuleView(name: acc.name, isSelected: acc.id == toAccountId)
            }
          }
        }
      }
    }
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

  private var feeSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Toggle(isOn: $includeFee.animation()) {
        Text("Include Transfer Fee")
          .font(.customFont(family: .quicksand, name: .bold, size: .x14))
          .foregroundStyle(Color.white)
      }
      .tint(Color.appPrimaryColor)
      if includeFee {
        AppTextfield(inputText: $feeString, placeHolder: "Fee amount", keyboardType: .decimalPad)
          .frame(height: 48)
      }
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

  private var confirmButton: some View {
    AppPrimaryButton(
      title: "Transfer",
      disable: .constant(!isValid),
      isLoading: $viewModel.isLoading
    ) {
      hideKeyboard()
      confirmTransfer()
    }
    .disabled(viewModel.isLoading)
  }

  private func setupDefaults() {
    if let first = assetAccounts.first { fromAccountId = first.id }
    if assetAccounts.count > 1 { toAccountId = assetAccounts[1].id }
  }

  private func confirmTransfer() {
    guard let amount = Double(amountString), amount > 0 else { return }
    guard let currency = AppData.prefCurrency?.code else { return }
    let fee: Double? = includeFee ? Double(feeString) : nil

    OverlayManager.shared.showPopup(
      title: "Confirm Transfer",
      message: "Transfer \(currency) \(String(format: "%.0f", amount)) between accounts?",
      style: .info,
      primaryAction: PopupAction(title: "Confirm", role: nil) {
        viewModel.addTransfer(
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          fee: fee,
          currency: currency,
          note: note.isEmpty ? nil : note
        )
      },
      secondaryAction: PopupAction(title: "Cancel", role: .cancel) {}
    )
  }
}
