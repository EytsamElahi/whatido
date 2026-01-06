//
//  TransactionFormViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI
import Combine

@MainActor
class AddSpendingViewModel: ObservableObject {
    private let service: SpendingsServiceProtocol
    private let projectService: ProjectsServiceProtocol

    // MARK: - Form Fields
    @Published var spendingItemTf: String = ""
    @Published var amountTf: Double = 0
    @Published var dateTf: String = ""
    @Published var selectedTypeName: String = "" {
        didSet {
            selectedType = spendingTypes.first(where: {$0.name == selectedTypeName})
        }
    }
    @Published var selectedFundingSource: String = "Cash"
    @Published var currentMonthInDateFormat: Date? = Date().getFirstDateOfMonth()
    // Dropdown Data
    @Published var spendingTypes: [SpendingType] = []
    @Published var fundingSources: [FundSource] = FundSource.allCases
    @Published var selectedType: SpendingType?
    
    // Linked Project
    @Published var selectedProject: ProjectDto?
    @Published var projects: [ProjectDto]?

    // State
    @Published var isDataUploading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var dismissSheet: Bool = false

    var spending: SpendingDto?
    // Edit Mode Helper
    var spendingIdToEdit: String?
    private var created: Date?
    private let overlayManager = OverlayManager.shared
    private let eventBus: PassthroughSubject<AppGlobalEvent, Never>

    init(service: SpendingsServiceProtocol = SpendingsService(), projectSerivce: ProjectsServiceProtocol = ProjectsService(), spendingToEdit: SpendingDto? = nil, eventBus: PassthroughSubject<AppGlobalEvent, Never>) {
        self.service = service
        self.projectService = projectSerivce
        self.eventBus = eventBus
        self.loadSpendingTypes()
        self.getProjects()

        if let spending = spendingToEdit {
            self.spendingIdToEdit = spending.id
            self.spendingItemTf = spending.name
            self.amountTf = spending.amount
            self.dateTf = spending.date.toDateReturnString() // Helper method
            self.selectedTypeName = spending.type
            self.selectedFundingSource = spending.fundSource?.rawValue ?? "Cash"
            self.created = spending.created
            // Project pre-fill logic view se pass hogi ya yahan handle hogi
        }
    }
    
    private func loadSpendingTypes() {
        self.spendingTypes = Helper.load("spending_types.json")
    }

    // MARK: - Save Action
    func saveSpending() {
        guard validateForm() else {
            showErrorAlert = true
            return
        }
        let date = dateTf.toTimeStamp(format: "MM/dd/yyyy") ?? Date()

        // Create Object
        let spending = Spending(
            name: spendingItemTf,
            amount: amountTf,
            date: date,
            spendingType: selectedType!,
            created: created ?? Date(),
            source: selectedFundingSource,
            projectType: ProjectInfo(id: selectedProject?.id, name: selectedProject?.name, icon: selectedProject?.icon), accountType: DAccountType() // TODO: - Pass Account Type value
        )
        Task {
            self.isDataUploading = true
            defer {
                self.isDataUploading = false
            }
            let result: AppResult<SpendingDto>
            if let id = spendingIdToEdit {
                spending.id = id
                let apiResult = await service.editSpending(spending, id: id)
                 if case .error(let error) = apiResult {
                     self.overlayManager.showToast(message: error, style: .error)
                     return
                 }
                self.overlayManager.showToast(message: PopupMessages.dataUpdatedMessage("Spending"), style: .success)
                eventBus.send(.reloadDashboard)
                self.spending = spending.convertToDto()

            } else {
                let apiResult = await service.addSpending(spending)
                switch apiResult {
                case .data(let newSpending):
                    self.spending = newSpending
                    eventBus.send(.reloadDashboard)
                    self.overlayManager.showToast(message: PopupMessages.dataAddedMessage("Spending"), style: .success)
                case .error(let error):
                    self.overlayManager.showToast(message: error, style: .error)
                    return
                default:
                    debugPrint("")
                }
            }
            dismissSheet = true
        }
    }
    
    private func validateForm() -> Bool {
        return !spendingItemTf.isEmpty && amountTf > 0.0 && selectedType != nil
    }

    private func getProjects() {
        Task {
            let result = await projectService.getProjects()
            if case .data(let data) = result {
                self.projects = data
            }
        }
    }
//    private func resetAddSpendingForm() {
//        self.spendingItemTf = ""
//        self.amountTf = 0.0
//        self.dateTf = ""
//        self.spendingType = nil
//        self.spendingTypeName = ""
//        self.fundingSName = ""
//    }
}
