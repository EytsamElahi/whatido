//
//  WhatISpendService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

protocol WhatISpendServiceType {
    func getAllSpendings() async throws -> [SpendingDto]
    func getSpendingsOfMonth(_ month: Date) async throws -> [SpendingDto]
    func getSpendingById(_ id: String) async throws -> SpendingDto?
    @discardableResult
    func addNewSpending(_ spending: Spending) async throws -> String
    func editSpending(_ spending: Spending, id: String) async throws
    func deleteSpending(_ documentId: String) async throws
    func addMonthlyBudget(_ budget: Budget) async throws
    func getMonthlyBudget(id: String) async throws -> Budget?
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
    
    func getSpendingById(_ id: String) async throws -> SpendingDto? {
        do {
            let endpoint = FirestoreEndpoints.getSpending(id: id)
            let spendingData: Spending = try await request(endpoint: endpoint)
            return spendingData.convertToDto()
        } catch {
            debugPrint("Error in fetching spendings", error.localizedDescription)
            throw error
        }
    }

    func getSpendingsOfMonth(_ month: Date) async throws -> [SpendingDto] {
        let filter = FirestoreDateFilter(key: "date", from: month, to: Date())
        do {
            let endpoint = FirestoreEndpoints.getAllSpendings
            let spendingsData: [Spending] = try await request(filter: filter, endpoint: endpoint)
            return spendingsData.map { $0.convertToDto() }

        } catch {
            debugPrint("Error in fetching spendings", error.localizedDescription)
            throw error
        }
    }
    
    @discardableResult
    func addNewSpending(_ spending: Spending) async throws -> String {
        do {
            let endpoint = FirestoreEndpoints.createSpending
           return try await post(data: spending, endpoint: endpoint)
        } catch {
            throw error
            debugPrint("Error in posting data", error.localizedDescription)
        }
    }
    
    func editSpending(_ spending: Spending, id: String) async throws {
        do {
            let endpoint = FirestoreEndpoints.editSpending(id: id)
            try await update(data: spending, endpoint: endpoint)
        } catch {
            debugPrint("Error in posting data", error.localizedDescription)
        }
    }
    
    func deleteSpending(_ documentId: String) async throws {
        do {
            let endpoint = FirestoreEndpoints.deleteSpending(id: documentId)
            try await delete(endpoint: endpoint)
        } catch {
            debugPrint("Error in deleting data", error.localizedDescription)
        }
    }

    func addMonthlyBudget(_ budget: Budget) async throws {
        do {
            let endpoint = FirestoreEndpoints.addBudget(year: budget.year, month: budget.month)
            try await post(data: budget, endpoint: endpoint)
        } catch {
            debugPrint("Error in Adding budget", error.localizedDescription)
        }
    }

    func getMonthlyBudget(id: String) async throws -> Budget? {
        do {
            let endpoint = FirestoreEndpoints.getBudget(id: id)
            return try await request(endpoint: endpoint)
        } catch {
            throw error
            debugPrint("Error in fetching budget", error.localizedDescription)
        }
    }

}


final class WhatISpendServiceStub: WhatISpendServiceType {
    func getAllSpendings() async throws -> [SpendingDto] { return []  }
    func addNewSpending(_ spending: Spending) async throws -> String  { return "" }
    func editSpending(_ spending: Spending, id: String) async throws { }
    func getSpendingById(_ id: String) async throws -> SpendingDto? { return nil }
    func deleteSpending(_ documentId: String) async throws {}
    func getSpendingsOfMonth(_ month: Date) async throws -> [SpendingDto] {return []}
    func addMonthlyBudget(_ budget: Budget) async throws {  }
    func getMonthlyBudget(id: String) async throws -> Budget? { return nil }
}
