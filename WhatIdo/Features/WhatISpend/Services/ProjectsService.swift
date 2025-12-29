//
//  ProjectsService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import Foundation

protocol ProjectsServiceProtocol {
    func getProjects() async -> AppResult<[ProjectDto]>
    func addProject(_ project: ProjectSpending) async -> AppResult<ProjectDto>
    func deleteProject(_ id: String) async -> AppResult<Void>
    func editProject(_ project: ProjectSpending) async -> AppResult<Void>
}

final class ProjectsService: FirebaseService, ProjectsServiceProtocol {
    
    func getProjects() async -> AppResult<[ProjectDto]> {
        do {
            let data: [ProjectSpending] = try await request(orderBy: "created", endpoint: FirestoreEndpoints.getAllProjects)
            let dtos = data.compactMap { $0.convertToDto() }
            return .data(dtos)
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func addProject(_ project: ProjectSpending) async -> AppResult<ProjectDto> {
        do {
            // Pehle save kiya
            let savedData = try await post(data: project, endpoint: FirestoreEndpoints.addProject(id: project.id))
            // Phir DTO wapis bheja taake UI update ho sake
            return .data(savedData.convertToDto())
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func deleteProject(_ id: String) async -> AppResult<Void> {
        do {
            let projectEndpoint = FirestoreEndpoints.editOrDeleteProject(id: id)
            let spendingEndpoint = FirestoreEndpoints.getAllSpendings
            let param = FirestoreQueryParam(key: "projectInfo.id", value: id)
            try await deleteAtomic(documentEndpoint: projectEndpoint, dependentCollectionEndpoint: spendingEndpoint, dependencyParam: param)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func editProject(_ project: ProjectSpending) async -> AppResult<Void> {
        do {
            let endpoint = FirestoreEndpoints.editOrDeleteProject(id: project.id)
            try await update(data: project, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
