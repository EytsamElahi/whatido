//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

struct AddSpendingView: View {
    @ObservedObject var viewModel: AddSpendingViewModel
    var selectedProject: ProjectDto?
    @Environment(\.dismiss) var dismiss
    var onSpendingAdded: (SpendingDto?) -> ()
    @State private var showAllCategories = false // Default: Collapsed

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
        // 🏠 Housing & Utilities
        case "rent", "housing":
            return "house.fill"
        case "utility bills", "bills", "utility bill", "maintenance":
            return "bolt.fill"
        // 🚗 Transport
        case "fuel", "petrol":
            return "fuelpump.fill"
        case "public transit / taxi", "travel", "transport":
            return "car.fill"
        // 🍔 Food
        case "groceries":
            return "cart.fill"
        case "dining out", "food", "dining":
            return "fork.knife"
        // 🏥 Health
        case "doctor & checkups", "health":
            return "stethoscope"
        case "pharmacy / meds", "medicine":
            return "pills.fill"
        // 💰 Finance
        case "loan repayment", "debt":
            return "banknote.fill"
        case "emergency fund", "savings":
            return "lock.shield.fill"
        // 🎬 Entertainment & Subs
        case "subscriptions", "subscription":
            return "repeat.circle.fill"
        case "movies & outings", "entertainment":
            return "popcorn.fill"
        // 📚 Education
        case "course & books", "education":
            return "book.closed.fill"
        // 💇‍♂️ Personal Care & Clothing (New)
        case "salon & grooming", "grooming":
            return "scissors"
        case "clothing & tailor", "shopping":
            return "tshirt.fill"
        // 🛍️ Shopping items
        case "electronics & gadgets":
            return "laptopcomputer"
        case "household items":
            return "lamp.floor.fill"
        // 🎁 Family & Gifts
        case "gifts / donations":
            return "gift.fill"
        case "family support", "allowance":
            return "figure.2.and.child.holdinghands"

        default:
            return "tag.fill"
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
                                .keyboardType(.decimalPad)
                                .font(.customFont(family: .inter, name: .bold, size: .x50))
                                .foregroundStyle(Color.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: true, vertical: true)
                                .tint(Color.appPrimaryColor)
                                .onChange(of: viewModel.amountTf) { newValue in
                                    if newValue > 999_999_9 {
                                        viewModel.amountTf = 999_999_9
                                    }
                                    if newValue < 0 {
                                        viewModel.amountTf = 0
                                    }
                                }
                        }
                    }

                    // MARK: - 2. Metadata (Note, Date, Source)
                    VStack(spacing: 15) {
                        AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "What is this for?", maxLength: 40)
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

                                // 🔥 LOGIC: Agar expanded hai to sab dikhao, warna sirf pehle 8
                            let categoriesToShow = showAllCategories ? viewModel.spendingTypes : Array(viewModel.spendingTypes.prefix(8))

                                ForEach(categoriesToShow, id: \.id) { category in
                                    VStack {
                                        // 1. Icon Circle
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.selectedType?.id == category.id ? Color.appPrimaryColor : Color.gray.opacity(0.2))
                                                .frame(width: 60, height: 60)

                                            Image(systemName: getIcon(for: category.name ?? "")) // Tumhara Helper Function
                                                .font(.system(size: 24))
                                                .foregroundStyle(viewModel.selectedType?.id == category.id ? .black : .white)
                                        }

                                        Text(category.name ?? "")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.8)
                                            .frame(height: 35, alignment: .top)
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            viewModel.selectedType = category
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        if viewModel.spendingTypes.count > 8 {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        showAllCategories.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(showAllCategories ? "Show Less" : "See All Categories")
                                            .font(.subheadline)
                                            .fontWeight(.medium)

                                        Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                                    }
                                    .foregroundStyle(Color.appPrimaryColor) // Tumhara yellow/brand color
                                    .padding(.top, 10)
                                }
                                .frame(maxWidth: .infinity) // Center align button
                            }
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
