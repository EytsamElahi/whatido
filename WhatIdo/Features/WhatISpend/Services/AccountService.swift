//
//  AccountService.swift
//  WhatIdo
//

import Foundation
import FirebaseFirestore

protocol AccountServiceProtocol {
  func getAllAccounts() async -> AppResult<[AccountDto]>
  func addAccount(_ account: Account) async -> AppResult<AccountDto>
  func getAllIncomeSources() async -> AppResult<[IncomeSourceDto]>
  func addIncomeSource(_ source: IncomeSource) async -> AppResult<IncomeSourceDto>
  func deleteAccount(_ id: String) async -> AppResult<Void>
  func deleteIncomeSource(_ id: String) async -> AppResult<Void>
  func editAccount(_ account: Account) async -> AppResult<Void>
  func editIncomeSource(_ source: IncomeSource) async -> AppResult<Void>
  func updateDefaultAccount(selectedId: String, allActiveAccounts: [AccountDto]) async -> AppResult<Void>
  func addIncomeTransaction(_ tx: IncomeTransaction) async -> AppResult<IncomeTransaction>
  func getIncomeTransactions() async -> AppResult<[IncomeTransaction]>
  func addTransfer(_ transfer: AccountTransfer) async -> AppResult<Void>
  func saveNetWorthSnapshot(_ snapshot: NetWorthSnapshot) async -> AppResult<Void>
  func recomputeAndSyncBalance(accountId: String) async -> AppResult<Double>
}

final class AccountService: FirebaseService, AccountServiceProtocol {

  // MARK: - Accounts

  func getAllAccounts() async -> AppResult<[AccountDto]> {
    do {
      let data: [Account] = try await request(orderBy: "created", endpoint: FirestoreEndpoints.getAllAccounts)
      let dtos = data.map { $0.convertToDto() }
      return .data(dtos)
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func addAccount(_ account: Account) async -> AppResult<AccountDto> {
    do {
      let savedAccount = try await post(data: account, endpoint: FirestoreEndpoints.createAccount(id: account.id))
      return .data(savedAccount.convertToDto())
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func deleteAccount(_ id: String) async -> AppResult<Void> {
    let endPoint = FirestoreEndpoints.createAccount(id: id)
    do {
      try await updateCollectionProperties(FirestoreQueryParam(key: "isArchived", value: true), endpoint: endPoint)
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func editAccount(_ account: Account) async -> AppResult<Void> {
    do {
      let _ = try await update(data: account, endpoint: FirestoreEndpoints.createAccount(id: account.id))
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func updateDefaultAccount(selectedId: String, allActiveAccounts: [AccountDto]) async -> AppResult<Void> {
    do {
      var instructions: [(endpoint: FirestoreEndpoint, params: [FirestoreQueryParam])] = []
      for acc in allActiveAccounts {
        let endpoint = FirestoreEndpoints.createAccount(id: acc.id)
        let isDefault = (acc.id == selectedId)
        instructions.append((
          endpoint: endpoint,
          params: [FirestoreQueryParam(key: "isDefault", value: isDefault)]
        ))
      }
      try await performBatchUpdate(instructions: instructions)
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  // MARK: - Income Sources

  func getAllIncomeSources() async -> AppResult<[IncomeSourceDto]> {
    do {
      let data: [IncomeSource] = try await request(orderBy: "created", endpoint: FirestoreEndpoints.getAllIncomeSources)
      let dtos = data.map { $0.convertToDto() }
      return .data(dtos)
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func addIncomeSource(_ source: IncomeSource) async -> AppResult<IncomeSourceDto> {
    do {
      let savedSource = try await post(data: source, endpoint: FirestoreEndpoints.createIncomeSource(id: source.id))
      return .data(savedSource.convertToDto())
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func deleteIncomeSource(_ id: String) async -> AppResult<Void> {
    let endpoint = FirestoreEndpoints.createIncomeSource(id: id)
    do {
      try await delete(endpoint: endpoint)
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func editIncomeSource(_ source: IncomeSource) async -> AppResult<Void> {
    do {
      let _ = try await update(data: source, endpoint: FirestoreEndpoints.createIncomeSource(id: source.id))
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  // MARK: - Income Transactions

  func addIncomeTransaction(_ tx: IncomeTransaction) async -> AppResult<IncomeTransaction> {
    guard let userId = AppData.user?.id else { return .error("User not found") }
    let db = Firestore.firestore()
    let batch = db.batch()

    // 1. Write the IncomeTransaction document
    let txRef = db.collection("incomeTransactions").document(tx.id)
    var txDict = tx.asDictionary()
    txDict["userId"] = userId
    txDict["created"] = FieldValue.serverTimestamp()
    txDict["updated"] = FieldValue.serverTimestamp()
    batch.setData(txDict, forDocument: txRef, merge: true)

    // 2. Write a credit AccountTransaction ledger entry
    let ledgerRef = db.collection("accountTransactions").document(UUID().uuidString)
    let ledgerTx = AccountTransaction(
      accountId: tx.accountId,
      amount: tx.amount,          // positive = credit
      type: .income,
      referenceId: tx.id,
      note: tx.note
    )
    var ledgerDict = ledgerTx.asDictionary()
    ledgerDict["userId"] = userId
    ledgerDict["created"] = FieldValue.serverTimestamp()
    ledgerDict["updated"] = FieldValue.serverTimestamp()
    batch.setData(ledgerDict, forDocument: ledgerRef, merge: true)

    // 3. Increment the account's cached balance
    let accountRef = db.collection("accounts").document(tx.accountId)
    batch.updateData([
      "currentBalance": FieldValue.increment(tx.amount),
      "lastTransactionAt": FieldValue.serverTimestamp()
    ], forDocument: accountRef)

    do {
      try await batch.commit()
      return .data(tx)
    } catch {
      return .error(error.localizedDescription)
    }
  }

  func getIncomeTransactions() async -> AppResult<[IncomeTransaction]> {
    do {
      let data: [IncomeTransaction] = try await request(
        orderBy: "receivedAt",
        endpoint: FirestoreEndpoints.getAllIncomeTransactions
      )
      return .data(data)
    } catch {
      return .error(error.localizedDescription)
    }
  }

  // MARK: - Transfers

  func addTransfer(_ transfer: AccountTransfer) async -> AppResult<Void> {
    guard let userId = AppData.user?.id else { return .error("User not found") }
    let db = Firestore.firestore()
    let batch = db.batch()

    let transferRef = db.collection("accountTransfers").document(transfer.id)
    var transferDict = transfer.asDictionary()
    transferDict["created"] = FieldValue.serverTimestamp()
    transferDict["updated"] = FieldValue.serverTimestamp()
    batch.setData(transferDict, forDocument: transferRef, merge: true)

    let debitId = UUID().uuidString
    let debitRef = db.collection("accountTransactions").document(debitId)
    let debitTx = AccountTransaction(
      accountId: transfer.fromAccountId,
      amount: -(transfer.amount + (transfer.fee ?? 0)),
      type: .transfer,
      referenceId: transfer.id,
      note: transfer.note
    )
    var debitDict = debitTx.asDictionary()
    debitDict["id"] = debitId
    debitDict["userId"] = userId
    debitDict["created"] = FieldValue.serverTimestamp()
    debitDict["updated"] = FieldValue.serverTimestamp()
    batch.setData(debitDict, forDocument: debitRef, merge: true)

    let creditId = UUID().uuidString
    let creditRef = db.collection("accountTransactions").document(creditId)
    let creditTx = AccountTransaction(
      accountId: transfer.toAccountId,
      amount: transfer.amount,
      type: .transfer,
      referenceId: transfer.id,
      note: transfer.note
    )
    var creditDict = creditTx.asDictionary()
    creditDict["id"] = creditId
    creditDict["userId"] = userId
    creditDict["created"] = FieldValue.serverTimestamp()
    creditDict["updated"] = FieldValue.serverTimestamp()
    batch.setData(creditDict, forDocument: creditRef, merge: true)

    let fromRef = db.collection("accounts").document(transfer.fromAccountId)
    batch.updateData([
      "currentBalance": FieldValue.increment(-(transfer.amount + (transfer.fee ?? 0))),
      "lastTransactionAt": FieldValue.serverTimestamp()
    ], forDocument: fromRef)

    let toRef = db.collection("accounts").document(transfer.toAccountId)
    batch.updateData([
      "currentBalance": FieldValue.increment(transfer.amount),
      "lastTransactionAt": FieldValue.serverTimestamp()
    ], forDocument: toRef)

    do {
      try await batch.commit()
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  // MARK: - Net Worth Snapshots

  func saveNetWorthSnapshot(_ snapshot: NetWorthSnapshot) async -> AppResult<Void> {
    do {
      let _ = try await post(data: snapshot, endpoint: FirestoreEndpoints.createNetWorthSnapshot(id: snapshot.id))
      return .success
    } catch {
      return .error(error.localizedDescription)
    }
  }

  // MARK: - Balance Recomputation

  func recomputeAndSyncBalance(accountId: String) async -> AppResult<Double> {
    let db = Firestore.firestore()
    do {
      let accountSnap = try await db.collection("accounts").document(accountId).getDocument()
      guard accountSnap.exists, let data = accountSnap.data() else {
        return .error("Account not found")
      }
      let openingBalance = data["openingBalance"] as? Double ?? 0

      let txSnap = try await db.collection("accountTransactions")
        .whereField("accountId", isEqualTo: accountId)
        .whereField("userId", isEqualTo: AppData.user?.id ?? "")
        .getDocuments()

      let totalTx = txSnap.documents.compactMap { $0.data()["amount"] as? Double }.reduce(0, +)
      let newBalance = openingBalance + totalTx

      try await db.collection("accounts").document(accountId).updateData([
        "currentBalance": newBalance,
        "lastTransactionAt": FieldValue.serverTimestamp()
      ])
      return .data(newBalance)
    } catch {
      return .error(error.localizedDescription)
    }
  }
}
