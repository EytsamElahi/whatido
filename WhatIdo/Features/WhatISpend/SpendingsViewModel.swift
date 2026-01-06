//
//  SpendingListViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import Foundation

class SpendingsViewModel: BaseViewModel {
    // MARK: - Data Members
    @Published var newSpending: Spending?
    @Published var currentMonthSpendings: [SpendingDto]?
    @Published var spendingItemTf: String = ""
    @Published var amountTf: Double = 0
    @Published var dateTf: String = ""
    @Published var spendingTypeName: String = "" {
        didSet {
            spendingType = spendingTypes.first(where: {$0.name == self.spendingTypeName})
        }
    }
    @Published var spendingTypes: [SpendingType] = []
    @Published var fundingSources: [FundSource] = FundSource.allCases
    @Published var fundingSName: String = ""
    @Published private(set) var totalSpending: Int = 0
    @Published var budgetAmountTf: String = ""
    private(set) var spendingSortTypes: [MenuItem] = [MenuItem(id: 0, name: "Date"), MenuItem(id: 1, name: "Amount")]
    @Published var spendingType: SpendingType?
    @Published var selectedSortType: MenuItem?
    @Published var allSpendings: [SpendingDto]?
    @Published var allSpendingsMonthYear: [Int: [MonthItem]]?
    @Published var currentMonth: String = Date().getMonthName()
    @Published var currentMonthInDateFormat: Date? = Date().getFirstDateOfMonth()
    @Published var currentMonthBudget: Budget?

    // MARK: - State Members
    @Published var showAddNewSpendingSheet: Bool = false
    @Published var isDataLoading: Bool = false
    @Published var isDataUploading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var showConfirmationAlert: Bool = false
    @Published var fetchingAllSpendings: Bool = false
    @Published var showMoreMonths: Bool = false
    @Published var showBudgetSettingSheet: Bool = false
    @Published var isBudgetDeleting: Bool = false
    @Published var budgetAmount: Double?
    @Published var monthlyBudget: Budget?
    var tempSpending: SpendingDto? // In case of edit
    var spendingToDelete: SpendingDto? // Temporarily holding to be deleting spending

    //MARK: - Projects related members
    @Published var projects: [ProjectDto]? // array of projects containing spendings that belongs to a project
    @Published var selectedProject: ProjectDto? 
    @Published var showAddProjectSheet: Bool = false
    @Published var projectSpendings: [SpendingDto]?
    @Published private(set) var totalProjectSpending: Int = 0

    var spendingService: WhatISpendServiceType
    init(spendingService: WhatISpendServiceType) {
        self.spendingService = spendingService
        super.init()
        self.loadSpendingTypes()
        self.fetchProjects()
      //  self.budgetAmount = AppData.budget?[currentMonth]
    }

    private func loadSpendingTypes() {
        let types: [SpendingType] = Helper.load("spending_types.json")
        self.spendingTypes = types
    }

    func addSpendingSheetAction() {
        if tempSpending == nil {
            addSpending()
        } else {
            updateSpending()
        }
    }
}

// MARK: - Fetching spendings
extension SpendingsViewModel {
    func fetchMonthlySpendings(_ month: String, year: Int) {
        if month == self.currentMonth {
            self.showMoreMonths = false
            return
        }
        let existedMonthlySpendings = self.allSpendings?.filter {$0.date.getMonthName() == month }
        self.currentMonth = month
        self.currentMonthInDateFormat = Utilities.dateFrom(monthName: month, year: year)?.getFirstDateOfMonth() ?? Date()
        self.showMoreMonths = false
        self.currentMonthSpendings = existedMonthlySpendings
        self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
    }
    func fetchCurrentMonthSpendings(date: Date? = nil) {
        isDataLoading = true
        guard let firstDateOfCurrentMonth = date else {return}
        Task {@MainActor in
            let spendings = try await spendingService.getSpendingsOfMonth(firstDateOfCurrentMonth)
            self.currentMonthSpendings = spendings
            self.getCurrentMonthBudget()
            self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.isDataLoading = false
        }
    }

    func fetchallSpendings() {
        self.fetchingAllSpendings = true
        Task {@MainActor in
            let spendings = try await spendingService.getAllSpendings()
            let allDates = spendings.compactMap{ $0.date }
            self.allSpendings = spendings
            self.allSpendingsMonthYear = groupDatesToMonthItems(dates: allDates)
            self.fetchingAllSpendings = false
        }
    }

}

// MARK: - Edit Spending
extension SpendingsViewModel {
    func editSpending(_ spending: SpendingDto) {
        self.tempSpending = spending
        self.spendingItemTf = spending.name
        self.amountTf = spending.amount
        self.dateTf = spending.date.toDateReturnString()
        spendingTypeName = spending.type
        self.fundingSName = spending.fundSource?.rawValue ?? "Cash"
        self.spendingType = spendingTypes.first { $0.name == spending.type }
        self.selectedProject = projects?.first {$0.id == spending.project?.id}
        self.showAddNewSpendingSheet = true
    }

    private func updateSpending() {
        isDataUploading = true
        mapDtoToDomainModelAndValidate()
        guard let spending = newSpending else {
            return
        }
        guard let spendingId = tempSpending?.id else {return}
        Task {@MainActor in
            try await spendingService.editSpending(spending, id: spendingId)
            let updatedSpending = try await spendingService.getSpendingById(spendingId)
            if let index = currentMonthSpendings?.firstIndex(where: { $0.id == spendingId }) {
                currentMonthSpendings?[index] = updatedSpending!
            }
            if let index = allSpendings?.firstIndex(where: { $0.id == spendingId }) {
                allSpendings?[index] = updatedSpending!
            }
            self.tempSpending = nil
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
        }
    }
}

// MARK: - Add New Spending
extension SpendingsViewModel {
    private func addSpending() {
        isDataUploading = true
        mapDtoToDomainModelAndValidate()
        guard let spending = newSpending else {
            return
        }
        Task {@MainActor in
           let id = try await spendingService.addNewSpending(spending)
            let recentAddedSpending = try await spendingService.getSpendingById(id)
            self.currentMonthSpendings?.append(recentAddedSpending!)
            self.updatedSorting()
            self.allSpendings?.append(recentAddedSpending!)
            self.totalSpending += Int(spending.amount)
            self.isDataUploading = false
            self.showAddNewSpendingSheet = false
            self.resetAddSpendingForm()
        }
    }

    private func mapDtoToDomainModelAndValidate() {
        guard validateAddSpendingForm() else {
            showErrorAlert = true
            self.isDataUploading = false
            return
        }
        let date = dateTf.toTimeStamp(format: "MM/dd/yyyy")
        guard let spendingType = spendingType else {return}
        newSpending = Spending(name: spendingItemTf, amount: amountTf, date: date ?? Date(), spendingType: spendingType, created: self.tempSpending?.created ?? Date(), source: fundingSName, projectType: ProjectInfo(id: selectedProject?.id, name: selectedProject?.name, icon: selectedProject?.icon), accountType: DAccountType())
    }

    private func validateAddSpendingForm() -> Bool {
        guard !spendingItemTf.isEmpty, amountTf > 0.0, let _ = dateTf.toTimeStamp(format: "MM/dd/yyyy"), let spendingType = spendingType, spendingType.id != 0 else {
            return false
        }
        return true
    }

     func resetAddSpendingForm() {
        self.spendingItemTf = ""
         self.amountTf = 0.0
        self.dateTf = ""
        self.spendingType = nil
        self.spendingTypeName = ""
        self.fundingSName = ""
        self.showAddNewSpendingSheet = false
    }
}

// MARK: - Delete Spending
extension SpendingsViewModel {
    func deleteSpending(at offsets: IndexSet) {
        let spendingsToDelete = offsets.map { currentMonthSpendings?[$0] }
        guard let firstSpending = spendingsToDelete.first else {return}
        guard let spending = firstSpending else {return}
        self.spendingToDelete = spending
        showConfirmationAlert = true
        
    }
    
    func confirmedDeleteSpending() {
        guard let spending = spendingToDelete else {return}
        Task {@MainActor in
            try await spendingService.deleteSpending(spending.id)
            self.currentMonthSpendings?.removeAll {$0.id == spending.id}
            self.totalSpending = self.currentMonthSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            self.spendingToDelete = nil
        }
    }
}

// MARK: - Filter
extension SpendingsViewModel {
    func updatedSorting() {
        guard let spendings = self.currentMonthSpendings else {
            return
        }
        if selectedSortType == nil {
            selectedSortType = MenuItem(id: 0, name: "Date")
        }
        let sortedSpendings = sortSpendings(spendings: spendings)
        self.currentMonthSpendings = sortedSpendings
    }
   private func sortSpendings(spendings: [SpendingDto]) -> [SpendingDto] {
        guard !spendings.isEmpty else {
           return []
        }
       guard let selectedSortType = selectedSortType else {return []}
        var sortedSpendings = [SpendingDto]()
        switch selectedSortType.id {
        case 0:
            sortedSpendings = spendings.sorted { (spending1, spending2) -> Bool in
                return spending1.date > spending2.date
            }
        case 1:
            sortedSpendings = spendings.sorted { (spending1, spending2) -> Bool in
                return spending1.amount > spending2.amount
            }
        default:
            return []
        }
        return sortedSpendings
    }
}

// MARK: - All Spendings Month Split
extension SpendingsViewModel {
    func groupDatesToMonthItems(dates: [Date]) -> [Int: [MonthItem]] {
        var result: [Int: Set<Int>] = [:]
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"

        // Group months (as Int) by year
        for date in dates {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            result[year, default: []].insert(month)
        }

        // Convert month numbers to MonthItem
        var namedResult: [Int: [MonthItem]] = [:]
        for (year, monthSet) in result {
            let sortedMonths = monthSet.sorted()
            let monthItems = sortedMonths.compactMap { month -> MonthItem? in
                var components = DateComponents()
                components.month = month
                components.day = 1
                if let date = calendar.date(from: components) {
                    let monthName = formatter.string(from: date)
                    return MonthItem(month: monthName, year: year)
                }
                return nil
            }
            namedResult[year] = monthItems
        }

        return namedResult
    }
}

// MARK: - Set a budget
extension SpendingsViewModel {
    private func setBudget() {
        guard let amount = budgetAmount else { return }
        self.isDataUploading = true
        let budget = Budget(month: self.currentMonth, year: self.currentMonthInDateFormat?.components.year ?? 0, budgetAmount: amount)
       // AppData.budget?[self.currentMonth] = Double(budgetAmountTf) ?? 0.0
        Task {@MainActor in
            let result = await spendingService.addMonthlyBudget(budget)
            switch result {
            case .data(let budget):
                self.monthlyBudget = budget
                self.budgetAmount = budget.budgetAmount
            case .error:
                debugPrint("Error in setting budget")
            default:
                debugPrint("")
            }
            self.isDataUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.showBudgetSettingSheet = false
            }
            self.currentMonth = Date().getMonthName()
        }
    }
    func getCurrentMonthBudget() {
        let id = "\(currentMonthInDateFormat?.components.year ?? 0)_\(self.currentMonth)"
        Task {@MainActor in
            let result = await spendingService.getMonthlyBudget(id: id)
            switch result {
            case .data(let budget):
                self.monthlyBudget = budget
                self.budgetAmount = budget.budgetAmount
            case .error(let error):
                debugPrint("Error in fetching budget \(error)")
            case .success:
                debugPrint("No budget found")
            default:
                debugPrint("Default")
            }

        }
    }
    func deleteBudget() {
        guard let budget = monthlyBudget else {return}
        self.isBudgetDeleting = true
        Task {@MainActor in
            try await spendingService.deleteMonthlyBudget(budget.id )
            self.budgetAmount = nil
            self.isBudgetDeleting = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.showBudgetSettingSheet = false
            }
        }
    }

    private func updateBudgetAmount() {
        guard let amount = budgetAmount else { return }
        guard let cBudget = monthlyBudget else {return}
        self.isDataUploading = true
        cBudget.budgetAmount = amount
        Task {@MainActor in
            let result = await spendingService.editMonthlyBudget(cBudget, id: cBudget.id)
            if case(.success) = result {
                self.budgetAmount = cBudget.budgetAmount
            } else {
                debugPrint("Error in fetching budget")
            }
            self.isDataUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.showBudgetSettingSheet = false
            }
        }
    }

    func setOrUpdateBudget() {
        if monthlyBudget ==  nil {
            setBudget()
        } else {
            updateBudgetAmount()
        }
    }

}

extension SpendingsViewModel {
    func fetchProjects() {
     //   isDataLoading = true
        Task {@MainActor in
            let result = await spendingService.getProjects()
            switch result {
            case .data(let projects):
                self.projects = projects
            case .error(let error):
                debugPrint("Error in fetching budget \(error)")
            case .success:
                debugPrint("No projects found")
            }
           // isDataLoading = false
        }
    }

    func createProject(name: String, icon: String, budget: Double? = nil) {
        let projectId = UUID().uuidString
        let project: ProjectSpending = ProjectSpending(id: projectId, name: name, budget: budget, icon: icon, status: "Active")
        self.isDataUploading = true
        Task {@MainActor in
            let result = await spendingService.addProject(project)
            switch result {
            case .data(let project):
                if self.projects.isNil {
                    self.projects = []
                }
                self.projects?.insert(project, at: 0)
            case .error(let error):
                debugPrint("Error in adding project \(error)")
            case .success:
                debugPrint("No Data")
            }
            self.isDataUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else {return}
                self.showAddProjectSheet = false
            }
        }
    }

    func updateProject(name: String, icon: String, budget: Double? = nil) {
        guard let existingProject = selectedProject else {return}
        let project: ProjectSpending = ProjectSpending(id: existingProject.id, name: name, budget: budget ?? existingProject.budget, icon: icon, status: existingProject.status, created: existingProject.createdAt)
        self.isDataUploading = true
        Task {@MainActor in
            let result = await spendingService.editProject(project)
            if case(.success) = result {
                guard let index = projects?.firstIndex(where: {$0.id == existingProject.id}) else { return }
                projects?[index] = project.convertToDto()
                self.selectedProject = nil
            } else {
                debugPrint("Error in fetching budget")
            }
            self.isDataUploading = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                guard let self = self else {return}
                self.showAddProjectSheet = false
            }
        }
    }

    func deleteProject(_ id: String) {
        self.isBudgetDeleting = true
        Task {@MainActor in
            let result = await spendingService.deleteProject(id)
            switch result {
            case .error(let error):
                debugPrint("Error in deleting of Project \(error)")
            default:
                self.projects?.removeAll(where: {$0.id == id})
                debugPrint("Deletion Succesful")
            }
            self.isBudgetDeleting = false
        }
    }

    func fetchProjectSpendings(_ id: String) {
        Task { @MainActor in
            isDataLoading = true
            let result = await spendingService.getProjectSpendings(id)
            switch result {
            case .data(let spendings):
                self.projectSpendings = spendings
                self.totalProjectSpending = self.projectSpendings?.reduce(0) { $0 + Int($1.amount) } ?? 0
            case .error(let error):
                debugPrint("error")
            case .success:
                debugPrint("")

            }
            self.isDataLoading = false
        }
    }
}
