//
//  ProjectsViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

@MainActor
class ProjectsViewModel: BaseViewModel {
    private let projectService: ProjectsServiceProtocol
    private let spendingService: SpendingsServiceProtocol // For fetching project details
    
    @Published var projects: [ProjectDto] = []
    @Published var selectedProject: ProjectDto? // For Edit
    @Published var projectSpendings: [SpendingDto]?
    @Published var totalProjectSpending: Int = 0
    // Edit State
    var spendingToEdit: SpendingDto? 
    // State
    @Published var isDataLoading: Bool = false
    @Published var isDataUploading: Bool = false
    @Published var showAddProjectSheet: Bool = false
    @Published var showAddNewSpendingSheet: Bool = false
    @Published var dataIsDeleting: Bool = false

    private let eventBus: PassthroughSubject<AppGlobalEvent, Never>
    private let overlayManager = OverlayManager.shared
    private let analytics = AnalyticsManager.shared

    init(projectService: ProjectsServiceProtocol = ProjectsService(), 
         spendingService: SpendingsServiceProtocol = SpendingsService(),
         eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
        self.projectService = projectService
        self.spendingService = spendingService
        self.eventBus = eventBus
        super.init()
        self.fetchProjects()
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
        let project = ProjectSpending(id: projectId, name: name, budget: budget, icon: icon, status: "Active")

        self.isDataUploading = true
        Task { [weak self] in 
            guard let self = self else { return }
            defer {
                self.isDataUploading = false
            }
            let result = await projectService.addProject(project)
            switch result {
            case .data(let newProject):
                var temProj = newProject
                temProj.createdAt = Date()
                self.projects.insert(temProj, at: 0)
                self.analytics.logProjectCreated(icon: icon)
                OverlayManager.shared.showToast(message: PopupMessages.dataAddedMessage("Project"), style: .success)
                self.showAddProjectSheet = false

            case .error(let errorMessage):
                OverlayManager.shared.showToast(message: errorMessage, style: .error)
            default:
                debugPrint("")
            }
        }
    }

    func updateProject(name: String, icon: String, budget: Double? = nil) {
        guard let existingProject = selectedProject else { return }
        // Prepare Object
        let project = ProjectSpending(
            id: existingProject.id,
            name: name,
            budget: budget ?? existingProject.budget,
            icon: icon,
            status: existingProject.status,
            created: existingProject.createdAt
        )

        self.isDataUploading = true
        Task { [weak self] in
            guard let self = self else { return }
            defer {
                self.isDataUploading = false
            }
            let result = await projectService.editProject(project)

            switch result {
            case .success, .data:
                if let index = projects.firstIndex(where: { $0.id == existingProject.id }) {
                    projects[index] = project.convertToDto()
                }

                OverlayManager.shared.showToast(message: PopupMessages.dataUpdatedMessage("Project"), style: .success)

                self.selectedProject = nil
                self.showAddProjectSheet = false

            case .error(let errorMessage):
                OverlayManager.shared.showToast(message: errorMessage, style: .error)
            }
        }
    }

    // TODO: - Add confirmation popup
    func deleteProject(_ id: String) {
        overlayManager.showPopup(
                title: "Delete Project?",
                message: "This will delete all spendings inside the project. Cannot be undone.",
                style: .warning,
                primaryAction: PopupAction(title: "Delete", role: .destructive) {
                    self.performDelete(id: id)
                },
                secondaryAction: PopupAction(title: "Cancel", role: .cancel) {
                    // Cancel logic (auto dismiss)
                }
            )
    }

    private func performDelete(id: String) {
        self.dataIsDeleting = true
        Task { [weak self] in
            guard let self = self else { return }

            defer {
                self.dataIsDeleting = false
            }

            let result = await projectService.deleteProject(id)

            // 4. Handle Result
            switch result {
            case .success, .data:
                withAnimation {
                    self.projects.removeAll(where: { $0.id == id })
                }
                self.eventBus.send(.reloadDashboard)
                OverlayManager.shared.showToast(message: "Project deleted successfully", style: .success)

            case .error(let errorMessage):
                OverlayManager.shared.showToast(message: errorMessage, style: .error)
            }
        }
    }
    // MARK: - Fetch Details
//    func fetchProjectSpendings(_ id: String) {
//        isDataLoading = true
//        Task {
//            defer {self.isDataLoading = false}
//            let result = await spendingService.getSpendingsForProject(id)
//            if case .data(let spendings) = result {
//                self.projectSpendings = spendings
//                await self.updateTotalSpending()
//            }
//        }
//    }
    func fetchProjectSpendings(_ id: String) {
        isDataLoading = true // Start loading spinner (for the initial cache load)
        
        Task {
            do {
                // This loop stays alive and listens for updates
                for try await dtos in spendingService.getSpendingsForProject(id) {
                    
                    self.projectSpendings = dtos
                    await self.updateTotalSpending()
                    
                    // Stop spinner immediately after the first batch (Cache) arrives
                    self.isDataLoading = false
                }
            } catch {
                print("Stream error: \(error.localizedDescription)")
                self.isDataLoading = false
            }
        }
    }

    func updateTotalSpending() async {
        guard let projectSpendings, !projectSpendings.isEmpty else {return}
        self.totalProjectSpending = projectSpendings.reduce(0) { $0 + Int($1.amount) }
    }
}
