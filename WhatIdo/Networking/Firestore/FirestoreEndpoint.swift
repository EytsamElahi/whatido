//
//  FirestoreEndpoint.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation
import FirebaseFirestore

protocol FirestoreEndpoint {
  var path: FirestoreReference { get }
  var firestore: Firestore { get }
}
extension FirestoreEndpoint {
  var firestore: Firestore {
    FirestoreManager.shared
  }
}
protocol FirestoreReference {}
extension DocumentReference: FirestoreReference { }
extension CollectionReference: FirestoreReference { }

enum FirestoreEndpoints: FirestoreEndpoint {
  case createSpending
  case getSpending(id: String)
  case getAllSpendings
  case editSpending(id: String)
  case deleteSpending(id: String)
  case addBudget(userId: String, year: Int, month: String)
  case getBudget(id: String)
  case editBudget(id: String)
  case deleteBudget(id: String)
  case getAllProjects
  case addProject(id: String)
  case editOrDeleteProject(id: String)
  case addUser(id: String)
  case editUser(id: String)
  case getAllAccounts
  case createAccount(id: String)
  case getAllIncomeSources
  case createIncomeSource(id: String)
  case createFeedback
  case createAccountTransaction(id: String)
  case createIncomeTransaction(id: String)
  case getAllIncomeTransactions
  case createAccountTransfer(id: String)
  case getAllAccountTransfers
  case createNetWorthSnapshot(id: String)
  case getAllNetWorthSnapshots

  var path: FirestoreReference {
    switch self {
    case .createSpending:
      return firestore.collection("spendings").document()
    case .getAllSpendings:
      return firestore.collection("spendings")
    case .editSpending(let documentId):
      return firestore.collection("spendings")
        .document(documentId)
    case .deleteSpending(let documentId):
      return firestore.collection("spendings").document(documentId)
    case .getSpending(let documentId):
      return firestore.collection("spendings").document(documentId)
    case .addBudget(let userId, let year, let month):
      return firestore.collection("budget").document("\(userId)_\(year)_\(month)")
    case .getBudget(let documentId):
      return firestore.collection("budget").document(documentId)
    case .editBudget(let documentId):
      return firestore.collection("budget").document(documentId)
    case .deleteBudget(let documentId):
      return firestore.collection("budget").document(documentId)
    case .getAllProjects:
      return firestore.collection("projects")
    case .addProject(let documentId):
      return firestore.collection("projects").document(documentId)
    case .editOrDeleteProject(let documentId):
      return firestore.collection("projects").document(documentId)
    case .addUser(let documentId):
      return firestore.collection("users").document(documentId)
    case .editUser(let documentId):
      return firestore.collection("users").document(documentId)
    case .getAllAccounts:
      return firestore.collection("accounts")
    case .createAccount(let id):
      return firestore.collection("accounts").document(id)
    case .getAllIncomeSources:
      return firestore.collection("income_sources")
    case .createIncomeSource(let id):
      return firestore.collection("income_sources").document(id)
    case .createFeedback:
      return firestore.collection("user_feedback").document()
    case .createAccountTransaction(let id):
      return firestore.collection("accountTransactions").document(id)
    case .createIncomeTransaction(let id):
      return firestore.collection("incomeTransactions").document(id)
    case .getAllIncomeTransactions:
      return firestore.collection("incomeTransactions")
    case .createAccountTransfer(let id):
      return firestore.collection("accountTransfers").document(id)
    case .getAllAccountTransfers:
      return firestore.collection("accountTransfers")
    case .createNetWorthSnapshot(let id):
      return firestore.collection("netWorthSnapshots").document(id)
    case .getAllNetWorthSnapshots:
      return firestore.collection("netWorthSnapshots")
    }
  }
}

private final class FirestoreManager {
  // Settings are configured in AppDelegate immediately after FirebaseApp.configure().
  // Accessing Firestore.firestore() here is safe — settings are already applied.
  static let shared: Firestore = Firestore.firestore()
}
