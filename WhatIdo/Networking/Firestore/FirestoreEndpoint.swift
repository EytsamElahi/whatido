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
        Firestore.firestore()
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
    case addBudget(year: Int, month: String)
    case getBudget(id: String)
    var path: FirestoreReference {
        switch self {
        case .createSpending:
            return firestore.collection("spendings").document()
        case .getAllSpendings:
            return firestore.collection("spendings")
        case .editSpending(let documentId):
            return firestore.collection("spendings").document(documentId)
        case .deleteSpending(let documentId):
            return firestore.collection("spendings").document(documentId)
        case .getSpending(let documentId):
            return firestore.collection("spendings").document(documentId)
        case .addBudget(let year, let month):
            return firestore.collection("budget").document("\(year)_\(month)")
        case .getBudget(let documentId):
            return firestore.collection("budget").document(documentId)
        }
    }
}
