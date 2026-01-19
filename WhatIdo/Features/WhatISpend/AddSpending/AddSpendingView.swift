//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI
import Combine

struct AddSpendingView: View {
    @ObservedObject var viewModel: AddSpendingViewModel
    var selectedProject: ProjectDto?
    @Environment(\.dismiss) var dismiss
    var onSpendingAdded: (SpendingDto?) -> ()
    @State private var showAllCategories = false // Default: Collapsed
    @ObservedObject var currencyManager = CurrencyManager.shared
    @State private var date = Date()
    @State var calendarId: UUID = UUID()

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
//                            Text("Rs")
//                                .font(.customFont(family: .quicksand, name: .bold, size: .x24))
//                                .foregroundStyle(Color.appPrimaryColor)
                            Text(currencyManager.currencyCode)
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
                        // MARK: - 3. CONTEXT CHIPS (Date, Account, Project) 🏷️
                        let month = viewModel.currentMonthInDateFormat ?? Date()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {

                                // A. Date Chip (Using Native DatePicker in compact mode)
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(Color.appPrimaryColor)
                                    Text(viewModel.dateTf.isEmpty ? "Today" : viewModel.dateTf)
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white.opacity(0.1)))
                                .overlay {
                                    DatePicker(selection: $date, in: month...(month.getMonthName() == Date().getMonthName() ? Date() : month.lastDateOfMonth() ?? Date()), displayedComponents: .date) {}
                                        .tint(Color.black)
                                        .labelsHidden()
                                        .contentShape(Rectangle())
                                        .opacity(0.011)
                                        .id(calendarId)
                                        .onTapGesture(count: 99, perform: {
                                            // overrides tap gesture to fix ios 17.1 bug
                                        })
                                }

                                // B. Account Chip (Menu)
                                Menu {
                                    ForEach(viewModel.fundingSources.compactMap { $0.rawValue }, id: \.self) { source in
                                        Button(source) {
                                            viewModel.selectedFundingSource = source
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "creditcard.fill")
                                            .foregroundStyle(Color.appPrimaryColor)
                                        Text(viewModel.selectedFundingSource.isEmpty ? "Unlinked" : viewModel.selectedFundingSource)
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.white.opacity(0.1)))
                                }

                                // C. Project Chip (Menu)
                                Menu {
                                    Button("None") { viewModel.selectedProject = nil }
                                    if let projects = viewModel.projects {
                                        ForEach(projects, id: \.id) { project in
                                            Button {
                                                viewModel.selectedProject = project
                                            } label: {
                                                Label(project.name, systemImage: project.icon)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: viewModel.selectedProject?.icon ?? "folder.fill")
                                            .foregroundStyle(Color.appPrimaryColor)
                                        Text(viewModel.selectedProject?.name ?? "Link Project")
                                            .foregroundStyle(viewModel.selectedProject == nil ? .gray : .white)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(viewModel.selectedProject == nil ? Color.white.opacity(0.05) : Color.appPrimaryColor.opacity(0.2)))
                                }
                            }
                        }

                    }
                    .padding(.horizontal)

                    // MARK: - 3. Category Grid
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Category")
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
                }.onChange(of: date) {oldVal, newVal in
                    viewModel.dateTf = newVal.toDateReturnString()
                    self.calendarId = UUID()
                }
        }.interactiveDismissDisabled(viewModel.isDataUploading)
         .hideKeyboardOnTapAround()
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("Missing Info"), message: Text("Please fill in the amount and category."), dismissButton: .default(Text("OK")))
        }
    }
}

//struct AddSpendingView: View {
//    @ObservedObject var viewModel: AddSpendingViewModel
//    var selectedProject: ProjectDto?
//    @Environment(\.dismiss) var dismiss
//    var onSpendingAdded: (SpendingDto?) -> ()
//
//    @State private var showAllCategories = false
//    @ObservedObject var currencyManager = CurrencyManager.shared
//
//    // Grid Layout
//    let columns = [
//        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
//    ]
//
//    // MARK: - 🧠 Smart Logic: Auto-Detect Category
//    func detectCategory(from text: String) {
//        let lower = text.lowercased()
//        var matchedName: String? = nil
//
//        // Simple Keywords Mapping
//        if lower.contains("food") || lower.contains("burger") || lower.contains("pizza") || lower.contains("lunch") || lower.contains("dinner") { matchedName = "Dining Out" }
//        else if lower.contains("fuel") || lower.contains("petrol") || lower.contains("uber") || lower.contains("ride") { matchedName = "Fuel" }
//        else if lower.contains("grocery") || lower.contains("milk") || lower.contains("veg") { matchedName = "Groceries" }
//        else if lower.contains("bill") || lower.contains("net") || lower.contains("electric") { matchedName = "Utility Bills" }
//        else if lower.contains("rent") { matchedName = "Rent" }
//        else if lower.contains("shop") || lower.contains("cloth") || lower.contains("shirt") { matchedName = "Clothing & Tailor" }
//
//        // Find and animate selection
//        if let name = matchedName,
//           let category = viewModel.spendingTypes.first(where: { $0.name?.lowercased() == name.lowercased() }) {
//            withAnimation(.spring()) {
//                viewModel.selectedType = category
//            }
//        } else if text == "" {
//            withAnimation(.spring()) {
//                viewModel.selectedType = nil
//            }
//        }
//    }
//
//    // Reuse your existing Icon Logic
//    func getIcon(for name: String) -> String {
//        switch name.lowercased() {
//        case "rent", "housing": return "house.fill"
//        case "utility bills", "bills", "utility bill", "maintenance": return "bolt.fill"
//        case "fuel", "petrol": return "fuelpump.fill"
//        case "public transit / taxi", "travel", "transport": return "car.fill"
//        case "groceries": return "cart.fill"
//        case "dining out", "food", "dining": return "fork.knife"
//        case "doctor & checkups", "health": return "stethoscope"
//        case "pharmacy / meds", "medicine": return "pills.fill"
//        case "loan repayment", "debt": return "banknote.fill"
//        case "emergency fund", "savings": return "lock.shield.fill"
//        case "subscriptions", "subscription": return "repeat.circle.fill"
//        case "movies & outings", "entertainment": return "popcorn.fill"
//        case "course & books", "education": return "book.closed.fill"
//        case "salon & grooming", "grooming": return "scissors"
//        case "clothing & tailor", "shopping": return "tshirt.fill"
//        case "electronics & gadgets": return "laptopcomputer"
//        case "household items": return "lamp.floor.fill"
//        case "gifts / donations": return "gift.fill"
//        case "family support", "allowance": return "figure.2.and.child.holdinghands"
//        default: return "tag.fill"
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            Color.cardBackground.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//
//                // Header / Title
//                Text(viewModel.spendingIdToEdit == nil ? "New Transaction" : "Update Transaction")
//                    .font(.customFont(family: .quicksand, name: .bold, size: .x18))
//                    .foregroundStyle(Color.white)
//                    .padding(.top, 20)
//
//                ScrollView(.vertical, showsIndicators: false) {
//                    VStack(spacing: 30) {
//
//                        // MARK: - 1. HERO AMOUNT SECTION 💰
//                        VStack(spacing: 5) {
//                            Text("Amount")
//                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
//                                .foregroundStyle(Color.gray)
//
//                            HStack(alignment: .firstTextBaseline, spacing: 5) {
//                                Text(currencyManager.currencyCode)
//                                    .font(.customFont(family: .quicksand, name: .bold, size: .x24))
//                                    .foregroundStyle(Color.appPrimaryColor)
//                                    .padding(.bottom, 8)
//
//                                TextField("0", value: $viewModel.amountTf, format: .number)
//                                    .keyboardType(.decimalPad)
//                                    .font(.customFont(family: .inter, name: .bold, size: .x50))
//                                    .foregroundStyle(Color.white)
//                                    .multilineTextAlignment(.center)
//                                    .fixedSize(horizontal: true, vertical: true)
//                                    .tint(Color.appPrimaryColor)
//                            }
//                        }
//                        .padding(.top, 20)
//
//                        // MARK: - 2. SMART INPUT ROW 🧠
//                        // Combines Description + Smart Icon
//                        HStack(spacing: 10) {
//                            // Dynamic Icon Bubble
//                            ZStack {
//                                Circle()
//                                    .fill(Color.appPrimaryColor.opacity(0.15))
//                                    .frame(width: 50, height: 50)
//
//                                // Auto-updating Icon
//                                Image(systemName: getIcon(for: viewModel.selectedType?.name ?? ""))
//                                    .foregroundStyle(Color.appPrimaryColor)
//                                    .font(.title2)
//                                    .animation(.spring(), value: viewModel.selectedType?.id)
//                            }
//
//                            AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "What is this for?", maxLength: 40)
//                                .frame(height: 50)
//                                .onChange(of: viewModel.spendingItemTf) { newValue in
//                                    detectCategory(from: newValue)
//                                }
//                        }
//                        .padding(15)
//                        ///.background(Color.white.opacity(0.05))
//                        .cornerRadius(20)
//                        //.padding(.horizontal)
//
//                        // MARK: - 3. CONTEXT CHIPS (Date, Account, Project) 🏷️
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 12) {
//
//                                // A. Date Chip (Using Native DatePicker in compact mode)
//                                HStack(spacing: 6) {
//                                    Image(systemName: "calendar")
//                                        .foregroundStyle(Color.appPrimaryColor)
//
//                                    // Binding to a Date object in VM (Assuming you have one, or convert string)
//                                    // For now, using a label that opens a picker if you wrap it
//                                    Text(viewModel.dateTf.isEmpty ? "Today" : viewModel.dateTf)
//                                        .foregroundStyle(.white)
//                                }
//                                .padding(.horizontal, 14)
//                                .padding(.vertical, 8)
//                                .background(Capsule().fill(Color.white.opacity(0.1)))
//                                .overlay {
//                                    // Invisible DatePicker overlay for "Today" feel
//                                     DatePicker("", selection: Binding(get: { Date() }, set: { _ in /* Update VM */ }), displayedComponents: .date)
//                                         .labelsHidden()
//                                         .colorMultiply(.clear)
//                                         .blendMode(.destinationOver)
//                                }
//
//                                // B. Account Chip (Menu)
//                                Menu {
//                                    ForEach(viewModel.fundingSources.compactMap { $0.rawValue }, id: \.self) { source in
//                                        Button(source) {
//                                            viewModel.selectedFundingSource = source
//                                        }
//                                    }
//                                } label: {
//                                    HStack(spacing: 6) {
//                                        Image(systemName: "creditcard.fill")
//                                            .foregroundStyle(Color.appPrimaryColor)
//                                        Text(viewModel.selectedFundingSource.isEmpty ? "Unlinked" : viewModel.selectedFundingSource)
//                                            .foregroundStyle(.white)
//                                    }
//                                    .padding(.horizontal, 14)
//                                    .padding(.vertical, 8)
//                                    .background(Capsule().fill(Color.white.opacity(0.1)))
//                                }
//
//                                // C. Project Chip (Menu)
//                                Menu {
//                                    Button("None") { viewModel.selectedProject = nil }
//                                    if let projects = viewModel.projects {
//                                        ForEach(projects, id: \.id) { project in
//                                            Button {
//                                                viewModel.selectedProject = project
//                                            } label: {
//                                                Label(project.name, systemImage: project.icon)
//                                            }
//                                        }
//                                    }
//                                } label: {
//                                    HStack(spacing: 6) {
//                                        Image(systemName: viewModel.selectedProject?.icon ?? "folder.fill")
//                                            .foregroundStyle(Color.appPrimaryColor)
//                                        Text(viewModel.selectedProject?.name ?? "Link Project")
//                                            .foregroundStyle(viewModel.selectedProject == nil ? .gray : .white)
//                                    }
//                                    .padding(.horizontal, 14)
//                                    .padding(.vertical, 8)
//                                    .background(Capsule().fill(viewModel.selectedProject == nil ? Color.white.opacity(0.05) : Color.appPrimaryColor.opacity(0.2)))
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//
//                        // MARK: - 4. CATEGORY GRID (Visual Selection)
//                        VStack(alignment: .leading, spacing: 15) {
//                            Text("Quick Category")
//                                .font(.customFont(family: .quicksand, name: .bold, size: .x16))
//                                .foregroundStyle(Color.gray)
//                                .padding(.leading)
//
//                            LazyVGrid(columns: columns, spacing: 20) {
//                                let categoriesToShow = showAllCategories ? viewModel.spendingTypes : Array(viewModel.spendingTypes.prefix(8))
//
//                                ForEach(categoriesToShow, id: \.id) { category in
//                                    VStack {
//                                        ZStack {
//                                            Circle()
//                                                .fill(viewModel.selectedType?.id == category.id ? Color.appPrimaryColor : Color.white.opacity(0.05))
//                                                .frame(width: 60, height: 60)
//
//                                            Image(systemName: getIcon(for: category.name ?? ""))
//                                                .font(.system(size: 24))
//                                                .foregroundStyle(viewModel.selectedType?.id == category.id ? .black : .white)
//                                        }
//
//                                        Text(category.name ?? "")
//                                            .font(.caption2)
//                                            .foregroundStyle(.white.opacity(0.8))
//                                            .lineLimit(1)
//                                            .minimumScaleFactor(0.8)
//                                    }
//                                    .onTapGesture {
//                                        withAnimation(.spring()) { viewModel.selectedType = category }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//
//                            // Show More Button
//                            if viewModel.spendingTypes.count > 8 {
//                                Button(action: { withAnimation { showAllCategories.toggle() }}) {
//                                    HStack {
//                                        Text(showAllCategories ? "Show Less" : "See All Categories")
//                                        Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
//                                    }
//                                    .font(.subheadline)
//                                    .foregroundStyle(Color.appPrimaryColor)
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.top, 10)
//                                }
//                            }
//                        }
//
//                        // MARK: - 5. ACTION BUTTON
//                        AppPrimaryButton(title: viewModel.spendingIdToEdit == nil ? "Save Spending" : "Update Transaction",
//                                         disable: .constant(false),
//                                         isLoading: $viewModel.isDataUploading) {
//                            viewModel.saveSpending()
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 20)
//                    }
//                }
//            }
//        }
//        .scrollDismissesKeyboard(.interactively)
//        .hideKeyboardOnTapAround()
//        .onChange(of: viewModel.dismissSheet) { _ in
//            onSpendingAdded(viewModel.spending)
//        }
//        .onAppear {
//            if let project = selectedProject {
//                viewModel.selectedProject = project
//            }
//        }
//        .alert(isPresented: $viewModel.showErrorAlert) {
//            Alert(title: Text("Missing Info"), message: Text("Please enter an amount."), dismissButton: .default(Text("OK")))
//        }
//    }
//}

#Preview {
    AddSpendingView(viewModel: AddSpendingViewModel(eventBus: PassthroughSubject<AppGlobalEvent, Never>()), selectedProject: nil, onSpendingAdded: {_ in})
}
