//
//  ProjectsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI

@MainActor
class ProjectsViewModel: BaseViewModel {
    private let projectService: ProjectsServiceProtocol
    private let spendingService: SpendingsServiceProtocol // For fetching project details
    
    @Published var projects: [ProjectDto] = []
    @Published var selectedProject: ProjectDto? // For Edit
    @Published var projectSpendings: [SpendingDto] = []
    @Published var totalProjectSpending: Int = 0
    // Edit State
    var spendingToEdit: SpendingDto? 
    // State
    @Published var isDataLoading: Bool = false
    @Published var isDataUploading: Bool = false
    @Published var showAddProjectSheet: Bool = false
    @Published var showAddNewSpendingSheet: Bool = false
    @Published var dataIsDeleting: Bool = false

    init(projectService: ProjectsServiceProtocol = ProjectsService(), 
         spendingService: SpendingsServiceProtocol = SpendingsService()) {
        self.projectService = projectService
        self.spendingService = spendingService
    }
    
    // MARK: - CRUD
    func fetchProjects() {
        Task {
            isDataLoading = true
            let result = await projectService.getProjects()
            if case .data(let data) = result {
                self.projects = data
            }
            isDataLoading = false
        }
    }
//    
//    func createOrUpdateProject(name: String, icon: String, budget: Double? = nil) {
//        let projectObj = ProjectSpending(id: selectedProject?.id ?? UUID().uuidString, name: name, budget: budget, icon: icon, status: "Active")
//        
//        Task {
//            if selectedProject == nil {
//                // Create
//                let result = await projectService.addProject(projectObj)
//                if case .data(let newProject) = result {
//                    projects.insert(newProject, at: 0)
//                }
//            } else {
//                // Update
//                _ = await projectService.editProject(projectObj)
//                // Refresh list logic here or update local array
//                fetchProjects() 
//            }
//            showAddProjectSheet = false
//        }
//    }

    func createProject(name: String, icon: String, budget: Double? = nil) {
        let projectId = UUID().uuidString
        let project: ProjectSpending = ProjectSpending(id: projectId, name: name, budget: budget, icon: icon, status: "Active")
        self.isDataUploading = true
        Task {@MainActor in
            let result = await projectService.addProject(project)
            if case .data(let newProject) = result {
                projects.insert(newProject, at: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else {return}
                    self.showAddProjectSheet = false
                }
                return
            }
            if case .error(let error) = result {
                debugPrint("Error in uploading project")
            }
        }
    }

    func updateProject(name: String, icon: String, budget: Double? = nil) {
        guard let existingProject = selectedProject else {return}
        let project: ProjectSpending = ProjectSpending(id: existingProject.id, name: name, budget: budget ?? existingProject.budget, icon: icon, status: existingProject.status, created: existingProject.createdAt)
        self.isDataUploading = true
        Task {@MainActor in
            let result = await projectService.editProject(project)
            if case(.success) = result {
                guard let index = projects.firstIndex(where: {$0.id == existingProject.id}) else { return }
                projects[index] = project.convertToDto()
                self.selectedProject = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                    guard let self = self else {return}
                    self.showAddProjectSheet = false
                }

            } else {
                debugPrint("Error in fetching budget")
            }
            self.isDataUploading = false

        }
    }

    func deleteProject(_ id: String) {
        Task {
            self.dataIsDeleting = true
            let result = await projectService.deleteProject(id)
            if case .success = result {
                projects.removeAll(where: {$0.id == id})
            }
            self.dataIsDeleting = false
        }
    }
    
    // MARK: - Fetch Details
    func fetchProjectSpendings(_ id: String) {
        isDataLoading = true
        Task {
            let result = await spendingService.getSpendingsForProject(id)
            if case .data(let spendings) = result {
                self.projectSpendings = spendings
                self.updateTotalSpending()
            }
            isDataLoading = false
        }
    }

    func updateTotalSpending() {
        guard !projectSpendings.isEmpty else {return}
        self.totalProjectSpending = projectSpendings.reduce(0) { $0 + Int($1.amount) }
    }
}
