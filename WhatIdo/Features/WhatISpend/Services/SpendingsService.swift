//
//  SpendingsService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import Foundation
import FirebaseFirestore

protocol SpendingsServiceProtocol {
    func getAllSpendings() async -> AppResult<[SpendingDto]>
    func getSpendingsOfMonth(_ month: Date) async -> AppResult<[SpendingDto]>
    func getSpendingsForProject(_ projectId: String) async -> AppResult<[SpendingDto]>
    func addSpending(_ spending: Spending) async -> AppResult<SpendingDto>
    func editSpending(_ spending: Spending, id: String) async -> AppResult<Void>
    func deleteSpending(_ id: String) async -> AppResult<Void>
}

final class SpendingsService: FirebaseService, SpendingsServiceProtocol {
    
    func getAllSpendings() async -> AppResult<[SpendingDto]> {
        do {
            let data: [Spending] = try await request(endpoint: FirestoreEndpoints.getAllSpendings)
            let dtos = data.map { $0.convertToDto() }
            return .data(dtos)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func getSpendingsForProject(_ projectId: String) async -> AppResult<[SpendingDto]> {
        let param = FirestoreQueryParam(key: "projectInfo.id", value: projectId)
        do {
            let data: [Spending] = try await request(param, endpoint: FirestoreEndpoints.getAllSpendings)
            let dtos = data.map { $0.convertToDto() }
            return .data(dtos)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func addSpending(_ spending: Spending) async -> AppResult<SpendingDto> {
        //        do {
        //            let spending = try await post(data: spending, endpoint: FirestoreEndpoints.createSpending)
        //            return .data(spending.convertToDto())
        //        } catch {
        //            return .error(error.localizedDescription)
        //        }
        do {
            // 1. Define where the balance update should happen
            guard let accId = spending.accountType.accountId else {
                return .error("Account missing")
            }

            let accountRef = FirestoreEndpoints.createAccount(id: accId)
            guard let ref = accountRef.path as? DocumentReference else {
                return .error(FirestoreServiceError.documentNotFound.localizedDescription)
            }

            // 2. Define the "Side Effect" (Amount minus karna)
            let sideEffects: [DocumentReference: [String: Any]] = [
                ref: ["currentBalance": FieldValue.increment(-spending.amount)]
            ]

            // 3. Call the generic function
            let result = try await postWithAtomicUpdate(
                data: spending,
                endpoint: FirestoreEndpoints.createSpending,
                atomicUpdates: sideEffects
            )

            return .data(result.convertToDto())

        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    // Note: Void use kiya kyunke humein return value nahi chahiye
    func editSpending(_ spending: Spending, id: String) async -> AppResult<Void> {
        do {
            try await update(data: spending, endpoint: FirestoreEndpoints.editSpending(id: id))
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func deleteSpending(_ id: String) async -> AppResult<Void> {
        do {
            try await delete(endpoint: FirestoreEndpoints.deleteSpending(id: id))
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func getSpendingsOfMonth(_ month: Date) async -> AppResult<[SpendingDto]>{
        let filter = FirestoreDateFilter(key: "date", from: month, to: Date())
        do {
            let endpoint = FirestoreEndpoints.getAllSpendings
            let spendingsData: [Spending] = try await request(filter: filter, endpoint: endpoint)
            return .data(spendingsData.map { $0.convertToDto() })

        } catch {
            return .error(error.localizedDescription)
        }
    }
}
