//
//  SpendingsService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import Foundation

protocol SpendingsServiceProtocol {
    func getAllSpendings() async -> AppResult<[SpendingDto]>
    func getSpendingsOfMonth(_ month: Date) async -> AppResult<[SpendingDto]>
    func getSpendingsForProject(_ projectId: String) async -> AppResult<[SpendingDto]>
    func addSpending(_ spending: Spending) async -> AppResult<SpendingDto>
    func editSpending(_ spending: Spending, id: String) async -> AppResult<Void>
    func deleteSpending(_ id: String) async -> AppResult<Void>
    func getSpendingsForProject(_ projectId: String) -> AsyncThrowingStream<[SpendingDto], Error>
    func getSpendingsOfMonth(_ month: Date) -> AsyncThrowingStream<[SpendingDto], Error>
    func getAllSpendings() -> AsyncThrowingStream<[SpendingDto], Error>
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

    @available(*, deprecated)
    func getSpendingsForProject(_ projectId: String) async -> AppResult<[SpendingDto]> {
        let param = FirestoreQueryParam(key: "projectInfo.id", value: projectId)
//        do {
//            let data: [Spending] = try await request(param, endpoint: FirestoreEndpoints.getAllSpendings)
//            let dtos = data.map { $0.convertToDto() }
//            return .data(dtos)
//        } catch {
//            return .error(error.localizedDescription)
        //        }
        do {
            // 1. Fetch [Spending] using the generic <Spending>
            for try await data in streamRequest(param, filter: nil, orderBy: nil, endpoint: FirestoreEndpoints.getAllSpendings) as AsyncThrowingStream<[Spending], Error>  {
                
                // 2. Convert [Spending] -> [SpendingDto]
                let dtos = data.map { $0.convertToDto() }
                
                return .data(dtos)
            }
            return .success
            
        } catch {
            // 5. Pass errors to the ViewModel
            return .error(error.localizedDescription)
        }
    }

    func addSpending(_ spending: Spending) async -> AppResult<SpendingDto> {
        do {
            let spending = try await post(data: spending, endpoint: FirestoreEndpoints.createSpending)
            return .data(spending.convertToDto())
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
    @available(*, deprecated)
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
    // Change return type from AppResult to AsyncThrowingStream
    func getSpendingsForProject(_ projectId: String) -> AsyncThrowingStream<[SpendingDto], Error> {
        
        let param = FirestoreQueryParam(key: "projectInfo.id", value: projectId)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // 1. Fetch [Spending] using the generic <Spending>
                    for try await data in streamRequest(param, filter: nil, orderBy: nil, endpoint: FirestoreEndpoints.getAllSpendings) as AsyncThrowingStream<[Spending], Error>  {
                        
                        // 2. Convert [Spending] -> [SpendingDto]
                        let dtos = data.map { $0.convertToDto() }
                        
                        // 3. Yield the result to the ViewModel
                        continuation.yield(dtos)
                    }
                    // 4. Finish when stream ends
                    continuation.finish()
                    
                } catch {
                    // 5. Pass errors to the ViewModel
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func getSpendingsOfMonth(_ month: Date) -> AsyncThrowingStream<[SpendingDto], Error> {
        let filter = FirestoreDateFilter(key: "date", from: month, to: Date())
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await data in streamRequest(filter: filter, endpoint: FirestoreEndpoints.getAllSpendings) as AsyncThrowingStream<[Spending], Error>  {
                        let dtos = data.map { $0.convertToDto() }
                        continuation.yield(dtos)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    func getAllSpendings() -> AsyncThrowingStream<[SpendingDto], Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {                    for try await data in streamRequest(endpoint: FirestoreEndpoints.getAllSpendings) as AsyncThrowingStream<[Spending], Error>  {
                        let dtos = data.map { $0.convertToDto() }
                        continuation.yield(dtos)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
