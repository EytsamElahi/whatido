//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AddSpendingView: View {
    @StateObject var viewModel: AddSpendingViewModel
    var selectedProject: ProjectDto?
    @Environment(\.dismiss) var dismiss
    var onSpendingAdded: (SpendingDto?) -> ()

    // Grid Layout for Categories
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Helper for Icons
    func getIcon(for name: String) -> String {
        switch name.lowercased() {
        case "rent", "housing": return "house.fill"
        case "utility bill", "bills": return "bolt.fill"
        case "fuel", "transport": return "fuelpump.fill"
        case "travel": return "airplane"
        case "groceries": return "cart.fill"
        case "food", "dining": return "fork.knife"
        case "health", "medicine": return "cross.case.fill"
        case "debt": return "creditcard.fill"
        case "savings": return "banknote.fill"
        case "subscription": return "arrow.triangle.2.circlepath"
        case "education": return "book.fill"
        default: return "tag.fill"
        }
    }
    fileprivate func ProjectCapsule(project: ProjectDto, isSelected: Bool) -> some View {
        return HStack(spacing: 6) {
            Image(systemName: project.icon)
            Text(project.name)
        }
        .font(.customFont(family: .quicksand, name: .medium, size: .x14))
        .foregroundStyle(isSelected ? Color.black : Color.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color.appPrimaryColor : Color.white.opacity(0.1))
        )
    }
    
    var body: some View {
        ZStack {
            // Background Color
            Color.cardBackground.ignoresSafeArea()

            // MARK: - SCROLLVIEW ADDED HERE
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    Text(viewModel.spendingIdToEdit == nil ? "New Transaction" : "Update Transaction")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                        .foregroundStyle(Color.white)
                        .padding(.top, 20)
                        .padding(.top, 20)
                    // MARK: - 1. Amount Input
                    VStack(spacing: 8) {
                        Text("Amount")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                            .foregroundStyle(Color.gray)

                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("Rs")
                                .font(.customFont(family: .quicksand, name: .bold, size: .x24))
                                .foregroundStyle(Color.appPrimaryColor)

                            TextField("0", value: $viewModel.amountTf, format: .number)
                                .keyboardType(.numberPad)
                                .font(.customFont(family: .inter, name: .bold, size: .x50))
                                .foregroundStyle(Color.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: true, vertical: true)
                                .tint(Color.appPrimaryColor)
                        }
                    }

                    // MARK: - 2. Metadata (Note, Date, Source)
                    VStack(spacing: 15) {
                        AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "What is this for?")
                            .frame(height: 50)

                        HStack(spacing: 12) {
                            CalendarFieldView(fieldInputText: $viewModel.dateTf, placeHolder: "Date", datePickerPosition: .start, datePickerRange: .past, month: viewModel.currentMonthInDateFormat ?? Date())
                                .frame(height: 50)

                            CustomPickerView(listing: viewModel.fundingSources.compactMap { $0.rawValue },
                                             pickedItem: $viewModel.selectedFundingSource)
                                .frame(height: 50)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 3. Category Grid
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Category")
                            .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                            .foregroundStyle(Color.white)
                            .padding(.leading)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.spendingTypes, id: \.id) { type in
                                let isSelected = viewModel.selectedType?.name == type.name

                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(isSelected ? Color.appPrimaryColor : Color.white.opacity(0.05))
                                            .frame(width: 55, height: 55)

                                        Image(systemName: getIcon(for: type.name ?? ""))
                                            .font(.system(size: 20))
                                            .foregroundStyle(isSelected ? Color.black : Color.white)
                                    }

                                    Text(type.name ?? "")
                                        .font(.customFont(family: .quicksand, name: .medium, size: .x10))
                                        .foregroundStyle(isSelected ? Color.appPrimaryColor : Color.gray)
                                        .lineLimit(1)
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        viewModel.selectedType = type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - 4. Project Link (NEW ADDITION 🚀)
                    // Sirf tab dikhayein agar projects exist karte hain

                    if let project = selectedProject {
                        ProjectCapsule(project: project, isSelected: true)
                    } else {
                        if let projects = viewModel.projects, !projects.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Link Project (Optional)")
                                    .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                                    .foregroundStyle(Color.white)
                                    .padding(.leading)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        // Option: None
                                        Button {
                                            withAnimation { viewModel.selectedProject = nil }
                                        } label: {
                                            Text("None")
                                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                                .foregroundStyle(viewModel.selectedProject == nil ? Color.black : Color.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Capsule()
                                                        .fill(viewModel.selectedProject == nil ? Color.appPrimaryColor : Color.white.opacity(0.1))
                                                )
                                        }

                                        // Option: Projects
                                        ForEach(projects, id: \.id) { project in
                                            let isSelected = viewModel.selectedProject?.id == project.id
                                            Button {
                                                withAnimation { viewModel.selectedProject = project }
                                            } label: {
                                                ProjectCapsule(project: project, isSelected: isSelected)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    // MARK: - 5. Action Button
                    AppPrimaryButton(title: viewModel.spendingIdToEdit == nil ? "Save" : "Update",
                                     disable: .constant(false),
                                     isLoading: $viewModel.isDataUploading) {
                        
                        viewModel.saveSpending()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30) // Extra padding for safe area
                }
            }.scrollDismissesKeyboard(.interactively) // iOS 16 feature: Scroll to dismiss keyboard
                .onChange(of: viewModel.dismissSheet) {
                    onSpendingAdded(viewModel.spending)
                }
                .onAppear {
                    if let project = selectedProject {
                        viewModel.selectedProject = project
                    }
                }
        }.interactiveDismissDisabled(viewModel.isDataUploading)
         .hideKeyboardOnTapAround()
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("Missing Info"), message: Text("Please fill in the amount and category."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
//    AddSpendingView()
//        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
