//
//  ProjectSpendingsListView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 18/12/2025.
//


import SwiftUI

struct ProjectSpendingsListView: View {
    @EnvironmentObject var navigation: NavigationManager
    let project: ProjectDto
    @StateObject var viewModel: ProjectsViewModel
    @Environment(\.dependencyContainer) var container
    @ObservedObject var currencyManager = CurrencyManager.shared

    var body: some View {
        ZStack {
            // 1. Background
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack {
                    Button(action: {
                        navigation.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                    }

                    // Icon + Name
                    HStack(spacing: 8) {
                        Image(systemName: project.icon)
                            .foregroundStyle(Color.appPrimaryColor)
                        Text(project.name)
                            .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    // 👇 NEW: Add Spending Button
                    Button {
                        viewModel.selectedProject = project
                        viewModel.spendingToEdit = nil
                        viewModel.showAddNewSpendingSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.appPrimaryColor)
                            .background(Color.white.clipShape(Circle())) // White BG taake pop kare
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)

                if viewModel.projectSpendings.isEmpty && !viewModel.isDataLoading {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        Text("No transactions yet")
                            .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                            .foregroundStyle(Color.gray)
                    }
                    Spacer()
                } else {
                    // MARK: - Spendings List
                    if viewModel.isDataLoading {
                        Spacer()
                        ProgressView().tint(Color.appPrimaryColor)
                        Spacer()
                    } else {
                        // MARK: - Summary Card (Total Spent)
                        VStack(spacing: 5) {
                            Text("Total Spent")
                                .font(.customFont(family: .quicksand, name: .medium, size: .x14))
                                .foregroundStyle(Color.gray)

                            Text("\(currencyManager.symbol) \(viewModel.totalProjectSpending)")
                                    .font(.customFont(family: .inter, name: .bold, size: .x30))
                                    .foregroundStyle(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.cardBackground)
                        .padding(.bottom, 20) // Separation from list
                        
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(viewModel.projectSpendings, id: \.id) { spending in
                                    // 🔥 Reusing your existing Card
                                    UpdatedSpendingRow(spending: spending, hideProject: true)
                                        .environmentObject(currencyManager)
                                        .onTapGesture {
                                            viewModel.spendingToEdit = spending
                                            viewModel.selectedProject = project
                                            viewModel.showAddNewSpendingSheet = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Load data when view opens
            viewModel.fetchProjectSpendings(project.id)
        }
        .sheet(isPresented: $viewModel.showAddNewSpendingSheet) {
            AddSpendingView(viewModel: container.makeTransactionFormViewModel(spendingToEdit: viewModel.spendingToEdit), selectedProject: viewModel.selectedProject,onSpendingAdded: { updatedSpending in
                viewModel.showAddNewSpendingSheet = false
                guard let updatedSpending = updatedSpending else {return}
                if let index = viewModel.projectSpendings.firstIndex(where: { $0.id == updatedSpending.id }) {
                    viewModel.projectSpendings[index] = updatedSpending
                } else {
                    viewModel.projectSpendings.insert(updatedSpending, at: 0)
                }
                viewModel.updateTotalSpending()
            }).environmentObject(viewModel)
                .presentationDetents([.medium, .large])
        }
    }
}
