//
//  WhatISpendService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

protocol WhatISpendServiceType {
    func getAllSpendings() async throws -> [SpendingDto]
    func addNewSpending(_ spending: Spending) async throws
    func editSpending(_ spending: Spending, id: String) async throws
    func deleteSpending()
}

final class WhatISpendService: WhatISpendServiceType, FirebaseService {

    func getAllSpendings() async throws -> [SpendingDto] {
        do {
            let endpoint = FirestoreEndpoints.getAllSpendings
            let spendingsData: [Spending] = try await request(endpoint: endpoint)
            return spendingsData.map { $0.convertToDto() }

        } catch {
            debugPrint("Error in fetching spendings", error.localizedDescription)
            throw error
        }
    }
    
    func addNewSpending(_ spending: Spending) async throws {
        do {
            let endpoint = FirestoreEndpoints.createSpending
            try await post(data: spending, endpoint: endpoint)
        } catch {
            debugPrint("Error in posting data", error.localizedDescription)
        }
    }
    
    func editSpending(_ spending: Spending, id: String) async throws {
        do {
            let endpoint = FirestoreEndpoints.editSpending(id: id)
            try await post(data: spending, endpoint: endpoint)
        } catch {
            debugPrint("Error in posting data", error.localizedDescription)
        }
    }
    
    func deleteSpending() {
        debugPrint("")
    }

}
