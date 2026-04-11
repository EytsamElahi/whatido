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
  @State private var showMoreOptions: Bool = false
  @State private var showConfirmAlert: Bool = false

  private var assetAccounts: [AccountDto] {
    viewModel.accounts.filter { !$0.type.isLiability }
  }

  private var toAccounts: [AccountDto] {
    viewModel.accounts.filter { $0.id != fromAccountId }
  }

  private var toAccount: AccountDto? {
    viewModel.accounts.first(where: { $0.id == toAccountId })
  }

  private var toAccountIsLiability: Bool {
    toAccount?.type.isLiability ?? false
  }

  private var maxPayableAmount: Double? {
    guard toAccountIsLiability else { return nil }
    return toAccount?.currentBalance
  }

  private var sheetHeight: CGFloat {
    var height: CGFloat = 410
    if showMoreOptions {
      height += includeFee ? 120 : 70
    }
    return height
  }

  private var isValid: Bool {
    guard let amount = Double(amountString), amount > 0 else { return false }
    guard !fromAccountId.isEmpty && !toAccountId.isEmpty && fromAccountId != toAccountId else { return false }
    if let max = maxPayableAmount { return amount <= max }
    return true
  }

  private var overpaymentWarning: String? {
    guard toAccountIsLiability, let amount = Double(amountString), let max = maxPayableAmount else { return nil }
    guard amount > max else { return nil }
    let currency = AppData.prefCurrency?.code ?? ""
    return "Max payable: \(currency) \(String(format: "%.0f", max))"
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
        moreOptionsToggle
        if showMoreOptions {
          feeSection
          noteField
        }
        confirmButton
      }
      .padding(.horizontal)
      .padding(.bottom, 8)
    }
    .onAppear { setupDefaults() }
    .onChange(of: fromAccountId) { _ in
      if toAccountId == fromAccountId { toAccountId = "" }
    }
    .alert("Confirm Transfer", isPresented: $showConfirmAlert) {
      Button("Confirm") { performTransfer() }
      Button("Cancel", role: .cancel) {}
    } message: {
      let currency = AppData.prefCurrency?.code ?? ""
      let amount = Double(amountString) ?? 0
      Text("Transfer \(currency) \(String(format: "%.0f", amount)) between accounts?")
    }
    .presentationDetents([.height(sheetHeight)])
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
      Text(toAccountIsLiability ? "Pay Debt To" : "To Account")
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
      HStack {
        Text("Amount")
          .font(.customFont(family: .quicksand, name: .bold, size: .x14))
          .foregroundStyle(Color.white)
        if let warning = overpaymentWarning {
          Spacer()
          Text(warning)
            .font(.customFont(family: .quicksand, name: .medium, size: .x12))
            .foregroundStyle(Color.red)
        }
      }
      AppTextfield(inputText: $amountString, placeHolder: "0.00", keyboardType: .decimalPad)
        .frame(height: 48)
    }
  }

  private var moreOptionsToggle: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.2)) { showMoreOptions.toggle() }
    } label: {
      HStack(spacing: 4) {
        Text(showMoreOptions ? "Less options" : "More options")
          .font(.customFont(family: .quicksand, name: .medium, size: .x12))
          .foregroundStyle(Color.gray)
        Image(systemName: showMoreOptions ? "chevron.up" : "chevron.down")
          .font(.caption)
          .foregroundStyle(Color.gray)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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
    guard Double(amountString) != nil else { return }
    hideKeyboard()
    showConfirmAlert = true
  }

  private func performTransfer() {
    guard let amount = Double(amountString), amount > 0 else { return }
    guard let currency = AppData.prefCurrency?.code else { return }
    let fee: Double? = includeFee ? Double(feeString) : nil
    viewModel.addTransfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      fee: fee,
      currency: currency,
      note: note.isEmpty ? nil : note
    )
  }
}
