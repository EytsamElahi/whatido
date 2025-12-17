//
//  AddSpendingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

//import SwiftUI
//
//struct AddSpendingView: View {
//    @EnvironmentObject var viewModel: SpendingsViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15){
//            Text( viewModel.tempSpending == nil ? "Add Spending" : "Update Spending")
//                .foregroundStyle(Color.black)
//                .font(.customFont(name: .bold, size: .x20))
//            AppTextfield(inputText: $viewModel.spendingItemTf, placeHolder: "Jot down spending")
//                .frame(height: 50)
//            HStack {
//                AppTextfield(inputText: $viewModel.amountTf, placeHolder: "Amount", keyboardType: .numberPad)
//                    .frame(height: 50)
//                CalendarFieldView(fieldInputText: $viewModel.dateTf, placeHolder: "Date", datePickerPosition: .start, datePickerRange: .past, month: viewModel.currentMonthInDateFormat ?? Date())
//                    .frame(height: 50)
//            }
//            HStack {
//                CustomPickerView(listing: viewModel.spendingTypes.compactMap {$0.name ?? ""}, pickedItem: $viewModel.spendingTypeName)
//                    .frame(height: 50)
//                CustomPickerView(listing: viewModel.fundingSources.compactMap {$0.rawValue}, pickedItem: $viewModel.fundingSName)
//                    .frame(height: 50)
//            }
//            Spacer()
//            AppPrimaryButton(title: viewModel.tempSpending == nil ? "Add" : "Update", cornerPadding: 0, disable: .constant(false), isLoading: $viewModel.isDataUploading, action: {
//                viewModel.addSpendingSheetAction()
//            })
//        }.padding()
//            .contentShape(Rectangle())
//            .alert(isPresented: $viewModel.showErrorAlert) {
//                Alert(title: Text("Error"), message: Text("One of the fields is empty"), dismissButton: .default(Text("Got it!")))
//            }
//            .hideKeyboardOnTapAround()
//    }
//}

import SwiftUI

struct AddSpendingView: View {
    @EnvironmentObject var viewModel: SpendingsViewModel
    @Environment(\.dismiss) var dismiss

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

    var body: some View {
        ZStack {
            // Background Color
            Color.cardBackground.ignoresSafeArea()

            // MARK: - SCROLLVIEW ADDED HERE
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    Text(viewModel.tempSpending == nil ? "New Transaction" : "Update Transaction")
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
//                            CalendarFieldView(fieldInputText: $viewModel.dateTf,
//                                              placeHolder: "Date",
//                                              datePickerPosition: .start,
//                                              datePickerRange: .past,
//                                              month: viewModel.currentMonthInDateFormat ?? Date())
//                                .frame(height: 50)
                            CalendarFieldView(fieldInputText: $viewModel.dateTf, placeHolder: "Date", datePickerPosition: .start, datePickerRange: .past, month: viewModel.currentMonthInDateFormat ?? Date())
                                .frame(height: 50)

                            CustomPickerView(listing: viewModel.fundingSources.compactMap { $0.rawValue },
                                             pickedItem: $viewModel.fundingSName)
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
                                let typeName = type.name ?? ""
                                let isSelected = viewModel.spendingTypeName == typeName

                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(isSelected ? Color.appPrimaryColor : Color.white.opacity(0.05))
                                            .frame(width: 55, height: 55)

                                        Image(systemName: getIcon(for: typeName))
                                            .font(.system(size: 20))
                                            .foregroundStyle(isSelected ? Color.black : Color.white)
                                    }

                                    Text(typeName)
                                        .font(.customFont(family: .quicksand, name: .medium, size: .x10))
                                        .foregroundStyle(isSelected ? Color.appPrimaryColor : Color.gray)
                                        .lineLimit(1)
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        viewModel.spendingTypeName = typeName
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - 4. Action Button
                    AppPrimaryButton(title: viewModel.tempSpending == nil ? "Save" : "Update",
                                     disable: .constant(false),
                                     isLoading: $viewModel.isDataUploading) {
                        viewModel.addSpendingSheetAction()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30) // Extra padding for safe area
                }
            }
            .scrollDismissesKeyboard(.interactively) // iOS 16 feature: Scroll to dismiss keyboard
        }
         .hideKeyboardOnTapAround()
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("Missing Info"), message: Text("Please fill in the amount and category."), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    AddSpendingView()
        .environmentObject(SpendingsViewModel(spendingService: WhatISpendServiceStub()))
}
