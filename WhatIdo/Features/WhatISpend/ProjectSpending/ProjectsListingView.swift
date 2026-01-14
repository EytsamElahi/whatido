//
//  ProjectsListingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI

struct ProjectsListingView: View {
    @StateObject var viewModel: ProjectsViewModel
    @EnvironmentObject var navigation: NavigationManager

    // Grid Layout (2 Columns)
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea() // Pure Black

            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header
                AppHeaderView(title: "My Projects", backAction: {
                    navigation.pop()
                })

                if viewModel.isDataLoading {
                    ProgressView().tint(Color.appPrimaryColor) // Loading is now Purple
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // MARK: - Projects Grid
                    ScrollView {
                        if !viewModel.projects.isEmpty {
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(viewModel.projects, id: \.id) { project in
                                    ProjectCardView(project: project,onEdit: {
                                        // Set project to edit -> Trigger Sheet
                                        viewModel.selectedProject = project
                                        viewModel.showAddProjectSheet = true
                                    },
                                                    onDelete: {
                                        viewModel.deleteProject(project.id)
                                    })
                                    .onTapGesture {
                                        navigation.push(screen: .projectSpendingsList(project))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // Empty State
                            VStack(spacing: 15) {
                                Spacer(minLength: 100)
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                Text("No projects yet")
                                    .font(.customFont(family: .quicksand, name: .medium, size: .x16))
                                    .foregroundStyle(Color.gray)
                                Text("Create a project to track specific events like 'House Construction' or 'Dubai Trip'")
                                    .font(.customFont(family: .quicksand, name: .regular, size: .x14))
                                    .foregroundStyle(Color.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                    }

                    // MARK: - Floating Add Button
                    Button {
                        viewModel.showAddProjectSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create New Project")
                        }
                        .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.appPrimaryColor)
                        .cornerRadius(16)
                        .shadow(color: Color.appPrimaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }

            } .loadingIndicator($viewModel.dataIsDeleting)
        }   .navigationBarHidden(true)
        //        // Sheet for Adding New Project
            .sheet(isPresented: $viewModel.showAddProjectSheet) {
                AddProjectView()
                    .environmentObject(viewModel)
                    .presentationDetents([.height(500)])
            }
    }
}

//struct ProjectCardView: View {
//    let project: ProjectDto
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Icon
//            ZStack {
//                Circle()
//                    .fill(Color.appBackground)
//                    .frame(width: 40, height: 40)
//                Image(systemName: project.icon)
//                    .foregroundStyle(Color.appPrimaryColor)
//                    .font(.system(size: 18))
//            }.padding(.top, 10)
//
//            // Name & Status
//            VStack(alignment: .leading, spacing: 4) {
//                Text(project.name)
//                    .font(.customFont(family: .quicksand, name: .bold, size: .x16))
//                    .foregroundStyle(Color.white)
//                    .lineLimit(1)
//
//                Text(project.status) // "Active"
//                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
//                    .foregroundStyle(Color.gray)
//            }
//
//            //Spacer()
//
//            // Budget/Spent (Placeholder logic)
//            Text("Tap to view")
//                .font(.customFont(family: .inter, name: .regular, size: .x12))
//                .foregroundStyle(Color.white.opacity(0.5))
//                .padding(.bottom, 10)
//        }
//        .padding()
//        .frame(height: 140)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.cardBackground)
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.white.opacity(0.05), lineWidth: 1)
//        )
//    }
//}

struct ProjectCardView: View {
    let project: ProjectDto
    // Callbacks for actions
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.appBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: project.icon)
                    .foregroundStyle(Color.appPrimaryColor)
                    .font(.system(size: 18))
            }

            // Name & Status
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.customFont(family: .quicksand, name: .bold, size: .x16))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Text(project.status) // "Active"
                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                    .foregroundStyle(Color.appPrimaryColor.opacity(0.8)) // Teal glow
            }
            // 🔥 NEW: Start Date at bottom
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                Text("Started: " + (project.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? ""))
                    .font(.customFont(family: .inter, name: .medium, size: .x10))
            }
            .foregroundStyle(Color.gray)
        }
        .padding()
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        // 🔥 MAGIC: Long Press Menu
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit Project", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
