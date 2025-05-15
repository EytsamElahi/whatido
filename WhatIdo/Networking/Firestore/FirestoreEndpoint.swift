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
    case getAllSpendings
    var path: FirestoreReference {
        switch self {
        case .createSpending:
            return firestore.collection("spendings").document()
        case .getAllSpendings:
            return firestore.collection("spendings")
        }
    }
}
