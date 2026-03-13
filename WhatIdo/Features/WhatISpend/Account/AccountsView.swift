//
//  AccountsView.swift
//  WhatIdo
//

import SwiftUI

struct AccountsView: View {
  @StateObject var viewModel: AccountsViewModel
  @EnvironmentObject var navigation: NavigationManager

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 0) {
        AppHeaderView(title: "Accounts", backAction: {
          navigation.pop()
        })
        VStack(spacing: 20) {
          NetWorthHeaderView(viewModel: viewModel)
          AccountTabPickerView(selectedTab: $viewModel.selectedTab)
          AccountTabContentView(viewModel: viewModel)
        }
      }
      AccountFabView(viewModel: viewModel)
    }
    .navigationBarBackButtonHidden()
    .onAppear {
      viewModel.fetchData()
      viewModel.fetchIncomeTransactions()
    }
    .sheet(isPresented: $viewModel.showAddSheet) {
      if viewModel.selectedTab == .accounts {
        AddAccountSheet(viewModel: viewModel)
      } else {
        AddSourceSheet(viewModel: viewModel)
      }
    }
    .sheet(isPresented: $viewModel.showAdjustSheet) {
      AdjustBalanceSheet(viewModel: viewModel)
    }
    .sheet(isPresented: $viewModel.showAddIncomeSheet) {
      AddIncomeTransactionSheet(viewModel: viewModel)
    }
    .sheet(isPresented: $viewModel.showTransferSheet) {
      AddTransferSheet(viewModel: viewModel)
    }
  }
}

// MARK: - Net Worth Header

private struct NetWorthHeaderView: View {
  @ObservedObject var viewModel: AccountsViewModel

  var body: some View {
    VStack(spacing: 6) {
      Text("What's Mine")
        .font(.subheadline)
        .foregroundColor(.gray)
      Text("\(CurrencyManager.shared.currencyCode) \(viewModel.netWorth, specifier: "%.0f")")
        .font(.system(size: 34, weight: .bold, design: .rounded))
        .foregroundColor(viewModel.netWorth < 0 ? .red : .white)
      HStack(spacing: 8) {
        Text("I Have: \(CurrencyManager.shared.currencyCode) \(viewModel.totalAssets, specifier: "%.0f")")
          .font(.caption)
          .foregroundColor(.green.opacity(0.8))
        Text("|")
          .font(.caption)
          .foregroundColor(.gray)
        Text("I Owe: \(CurrencyManager.shared.currencyCode) \(viewModel.totalLiabilities, specifier: "%.0f")")
          .font(.caption)
          .foregroundColor(.red.opacity(0.8))
      }
    }
    .padding(.top, 8)
  }
}

// MARK: - Tab Picker

private struct AccountTabPickerView: View {
  @Binding var selectedTab: AccountTab

  var body: some View {
    Picker("", selection: $selectedTab) {
      ForEach(AccountTab.allCases, id: \.self) { tab in
        Text(tab.rawValue).tag(tab)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal)
    .onAppear {
      UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appPrimaryColor)
      UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
      UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
  }
}

// MARK: - Tab Content

private struct AccountTabContentView: View {
  @ObservedObject var viewModel: AccountsViewModel

  var body: some View {
    switch viewModel.selectedTab {
    case .accounts:
      AccountsListView(viewModel: viewModel)
    case .income:
      IncomeTransactionsListView(viewModel: viewModel)
    case .sources:
      SourcesListView(viewModel: viewModel)
    }
  }
}

// MARK: - Accounts List (Assets + Liabilities)

private struct AccountsListView: View {
  @ObservedObject var viewModel: AccountsViewModel

  private var assetAccounts: [AccountDto] {
    viewModel.accounts.filter { !$0.type.isLiability }
  }
  private var liabilityAccounts: [AccountDto] {
    viewModel.accounts.filter { $0.type.isLiability }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        if !assetAccounts.isEmpty {
          SectionHeader(title: "Assets")
          ForEach(assetAccounts, id: \.self) { account in
            AccountCardView(account: account, onEdit: {
              viewModel.editAccount(account)
            }, onDelete: {
              viewModel.deleteAccount(account.id)
            }, onBalanceAdjustment: {
              viewModel.selectedAccount = account
              viewModel.showAdjustSheet.toggle()
            }, onMarkAsDefault: {
              viewModel.markAsDefault(account: account)
            })
          }
        }
        if !liabilityAccounts.isEmpty {
          SectionHeader(title: "Liabilities")
          ForEach(liabilityAccounts, id: \.self) { account in
            AccountCardView(account: account, onEdit: {
              viewModel.editAccount(account)
            }, onDelete: {
              viewModel.deleteAccount(account.id)
            }, onBalanceAdjustment: {
              viewModel.selectedAccount = account
              viewModel.showAdjustSheet.toggle()
            }, onMarkAsDefault: {
              viewModel.markAsDefault(account: account)
            })
          }
        }
      }
      .padding()
    }
  }
}

private struct SectionHeader: View {
  let title: String
  var body: some View {
    HStack {
      Text(title)
        .font(.headline)
        .foregroundColor(.gray)
      Spacer()
    }
    .padding(.horizontal, 4)
  }
}

// MARK: - Income Transactions List

private struct IncomeTransactionsListView: View {
  @ObservedObject var viewModel: AccountsViewModel

  var body: some View {
    if viewModel.incomeTransactions.isEmpty {
      Spacer()
      VStack(spacing: 12) {
        Image(systemName: "tray")
          .font(.largeTitle)
          .foregroundColor(.gray)
        Text("No income recorded yet")
          .font(.subheadline)
          .foregroundColor(.gray)
      }
      Spacer()
    } else {
      List {
        ForEach(viewModel.incomeTransactions) { tx in
          IncomeTransactionRowView(tx: tx)
            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
  }
}

private struct IncomeTransactionRowView: View {
  let tx: IncomeTransactionDto

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: IncomeSource.getAutoIcon(forName: tx.sourceName))
        .font(.title2)
        .foregroundColor(Color.appPrimaryColor)
        .frame(width: 40, height: 40)
        .background(Color.gray.opacity(0.2))
        .clipShape(Circle())
      VStack(alignment: .leading, spacing: 4) {
        Text(tx.sourceName)
          .font(.headline)
          .foregroundColor(.white)
        Text(tx.accountName)
          .font(.caption)
          .foregroundColor(.gray)
      }
      Spacer()
      VStack(alignment: .trailing, spacing: 4) {
        Text("+\(CurrencyManager.shared.currencyCode) \(tx.amount, specifier: "%.0f")")
          .font(.headline)
          .foregroundColor(.green)
        Text(tx.receivedAt, style: .date)
          .font(.caption)
          .foregroundColor(.gray)
      }
    }
    .padding()
    .background(Color(uiColor: .systemGray6).opacity(0.1))
    .cornerRadius(12)
  }
}

// MARK: - Sources List

private struct SourcesListView: View {
  @ObservedObject var viewModel: AccountsViewModel

  var body: some View {
    List {
      ForEach(viewModel.incomeSources, id: \.self) { source in
        SourceRowView(source: source)
          .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          .onTapGesture { viewModel.editSource(source) }
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
              if let index = viewModel.incomeSources.firstIndex(of: source) {
                viewModel.deleteIncomeSource(index)
              }
            } label: {
              Image(systemName: "trash")
            }
            .tint(.red)
          }
      }
    }
    .id(viewModel.listRefreshID)
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
  }
}

// MARK: - FAB

private struct AccountFabView: View {
  @ObservedObject var viewModel: AccountsViewModel

  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        HStack(spacing: 12) {
          if viewModel.selectedTab == .accounts {
            Button {
              viewModel.showTransferSheet = true
            } label: {
              Image(systemName: "arrow.left.arrow.right")
                .font(.title2.bold())
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.appPrimaryColor.opacity(0.7))
                .clipShape(Circle())
            }
          }
          Button {
            viewModel.openSheet(tab: viewModel.selectedTab)
          } label: {
            Image(systemName: "plus")
              .font(.title2.bold())
              .foregroundColor(.black)
              .frame(width: 56, height: 56)
              .background(Color.appPrimaryColor)
              .clipShape(Circle())
          }
        }
        .padding()
      }
    }
  }
}

// MARK: - Source Row

struct SourceRowView: View {
  let source: IncomeSourceDto

  var body: some View {
    HStack {
      Image(systemName: source.icon)
        .font(.title2)
        .foregroundColor(Color.appPrimaryColor)
        .frame(width: 40, height: 40)
        .background(Color.gray.opacity(0.2))
        .clipShape(Circle())
      Text(source.name)
        .font(.headline)
        .foregroundColor(.white)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
        .font(.caption)
    }
    .padding()
    .background(Color(uiColor: .systemGray6).opacity(0.1))
    .cornerRadius(12)
  }
}

#Preview {
  AccountsView(viewModel: AccountsViewModel(service: AccountService()))
}

// MARK: - Adjust Balance Sheet

struct AdjustBalanceSheet: View {
  @ObservedObject var viewModel: AccountsViewModel
  @State private var newBalance: Double? = nil
  @State private var newBalanceString: String = ""

  var body: some View {
    ZStack {
      Color.cardBackground.ignoresSafeArea()
      VStack(spacing: 15) {
        Capsule()
          .frame(width: 40, height: 5)
          .foregroundStyle(Color.gray.opacity(0.3))
          .padding(.top, 10)
        VStack(spacing: 10) {
          Text("Adjust Balance")
            .font(.customFont(family: .quicksand, name: .bold, size: .x20))
            .foregroundStyle(Color.white)
          VStack(spacing: 5) {
            Text("Current Recorded Balance")
              .font(.customFont(family: .quicksand, name: .medium, size: .x14))
              .foregroundStyle(Color.gray)
            Text("\(CurrencyManager.shared.symbol) \(viewModel.selectedAccount?.currentBalance ?? 0, specifier: "%.2f")")
              .font(.customFont(family: .quicksand, name: .bold, size: .x24))
              .foregroundStyle(Color.appPrimaryColor)
          }
          .padding(.vertical, 10)
          VStack(alignment: .leading, spacing: 12) {
            Text("New Actual Balance")
              .font(.customFont(family: .quicksand, name: .bold, size: .x16))
              .foregroundStyle(Color.white)
            AppTextfield(inputText: $newBalanceString,
                         placeHolder: "Enter actual amount...", keyboardType: .decimalPad)
              .frame(height: 50)
          }
        }
        Spacer()
        AppPrimaryButton(
          title: "Confirm Adjustment",
          disable: .constant(newBalanceString.isEmpty),
          isLoading: $viewModel.isLoading
        ) {
          hideKeyboard()
          if let val = Double(newBalanceString) {
            viewModel.adjustAccountBalance(to: val)
          }
        }
        .padding(.vertical, 10)
        .disabled(viewModel.isLoading)
      }
      .padding()
    }
    .onAppear {
      if let current = viewModel.selectedAccount?.currentBalance {
        newBalanceString = String(format: "%.0f", current)
      }
    }
    .presentationDetents([.height(350)])
    .presentationDragIndicator(.hidden)
  }
}
