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
    case addBudget(userId: String, year: Int, month: String)
    case getBudget(id: String)
    case editBudget(id: String)
    case deleteBudget(id: String)
    case getAllProjects
    case addProject(id: String)
    case editOrDeleteProject(id: String)
    case addUser(id: String)
    case editUser(id: String)
    case getAllGoals
    case addGoal(id: String)
    case editGoal(id: String)
    case createFeedback

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
        case .getAllGoals:
            return firestore.collection("goals")
        case .addGoal(let documentId):
            return firestore.collection("goals").document(documentId)
        case .editGoal(let documentId):
            return firestore.collection("goals").document(documentId)
        case .createFeedback:
            return firestore.collection("user_feedback").document()
        }
    }
}
