//
//  WhatISpendService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

protocol AppDataType {}
enum AppResult<T: AppDataType> {
    case data(_ data: T)
    case error(_ error: String)
    case noData
}
extension Array: AppDataType where Element: AppDataType {}
protocol WhatISpendServiceType {
    func getAllSpendings() async throws -> [SpendingDto]
    func getSpendingsOfMonth(_ month: Date) async throws -> [SpendingDto]
    func getSpendingById(_ id: String) async throws -> SpendingDto?
    @discardableResult
    func addNewSpending(_ spending: Spending) async throws -> String
    func editSpending(_ spending: Spending, id: String) async throws
    func deleteSpending(_ documentId: String) async throws
    func addMonthlyBudget(_ budget: Budget) async -> AppResult<Budget>
    func getMonthlyBudget(id: String) async -> AppResult<Budget>?
    func deleteMonthlyBudget(_ documentId: String) async throws
    func editMonthlyBudget(_ budget: Budget, id: String) async -> AppResult<Budget>
    func getProjects() async -> AppResult<[ProjectDto]>
    func addProject(_ project: ProjectSpending) async -> AppResult<ProjectDto>
    func editProject(_ project: ProjectSpending) async -> AppResult<ProjectDto>
    func deleteProject(_ id: String) async -> AppResult<ProjectDto>
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

    func addMonthlyBudget(_ budget: Budget) async  -> AppResult<Budget> {
        do {
            let endpoint = FirestoreEndpoints.addBudget(year: budget.year, month: budget.month)
            let budget = try await postV2(data: budget, endpoint: endpoint)
            return .data(budget)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func getMonthlyBudget(id: String) async -> AppResult<Budget>? {
        do {
            let endpoint = FirestoreEndpoints.getBudget(id: id)
            let budget: Budget = try await request(endpoint: endpoint)
            return .data(budget)
        } catch {
            if let error = error as? FirestoreServiceError, error == .documentNotFound {
                return .noData
            }
            return .error(error.localizedDescription)
        }
    }
    func deleteMonthlyBudget(_ documentId: String) async throws {
        do {
            let endpoint = FirestoreEndpoints.deleteBudget(id: documentId)
            try await delete(endpoint: endpoint)
        } catch {
            debugPrint("Error in deleting data", error.localizedDescription)
        }
    }
    func editMonthlyBudget(_ budget: Budget, id: String) async -> AppResult<Budget> {
        do {
            let endpoint = FirestoreEndpoints.editBudget(id: id)
            try await update(data: budget, endpoint: endpoint)
            return .noData
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func getProjects() async -> AppResult<[ProjectDto]> {
        do {
            let endpoint = FirestoreEndpoints.getAllProjects
            let projects: [ProjectSpending] = try await request(endpoint: endpoint)
            let dto = projects.compactMap { $0.convertToDto() }
            return .data(dto)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func addProject(_ project: ProjectSpending) async -> AppResult<ProjectDto> {
        do {
            let endpoint = FirestoreEndpoints.addProject(id: project.id)
            let project = try await postV2(data: project, endpoint: endpoint)
            return .data(project.convertToDto())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func editProject(_ project: ProjectSpending) async -> AppResult<ProjectDto> {
        do {
            let endpoint = FirestoreEndpoints.editOrDeleteProject(id: project.id)
            try await update(data: project, endpoint: endpoint)
            return .noData
        } catch {
            return .error(error.localizedDescription)
        }
    }
    func deleteProject(_ id: String) async -> AppResult<ProjectDto> {
        do {
            let endpoint = FirestoreEndpoints.editOrDeleteProject(id: id)
            try await delete(endpoint: endpoint)
            return .noData
        } catch {
            return .error(error.localizedDescription)
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
    func addMonthlyBudget(_ budget: Budget) async  -> AppResult<Budget> {  return .noData }
    func getMonthlyBudget(id: String) async -> AppResult<Budget>? { return nil }
    func deleteMonthlyBudget(_ documentId: String) async throws {}
    func editMonthlyBudget(_ budget: Budget, id: String) async -> AppResult<Budget>{return .noData}
    func getProjects() async -> AppResult<[ProjectDto]> {return .noData}
    func addProject(_ project: ProjectSpending) async  -> AppResult<ProjectDto> {return .noData}
    func editProject(_ project: ProjectSpending) async -> AppResult<ProjectDto> {return .noData}
    func deleteProject(_ id: String) async -> AppResult<ProjectDto> {return .noData}
}
