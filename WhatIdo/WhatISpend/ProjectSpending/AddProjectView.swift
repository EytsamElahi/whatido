//
//  AddProjectView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI

struct AddProjectView: View {
    @EnvironmentObject var viewModel: ProjectsViewModel

    @State private var projectName = ""
    @State private var selectedIcon = "house.fill"

    // 🔥 Refined Categories (Essential Only)
    let icons = [
        "house.fill",           // 🏠 Construction / Home
        "hammer.fill",          // 🛠️ Renovation / Repairs
        "car.fill",             // 🚗 Car / Bike
        "airplane",             // ✈️ Travel / Trips
        "cart.fill",            // 🛍️ Shopping / Dowry (Jahez) etc
        "graduationcap.fill",   // 🎓 Education / Degree
        "desktopcomputer",      // 💻 Tech Setup / Work
        "gamecontroller.fill",  // 🎮 Gaming / Hobbies
        "party.popper.fill",    // 🎉 Events / Parties
        "heart.fill",           // ❤️ Wedding / Gifts
        "cross.case.fill",      // 🏥 Medical Treatments
        "banknote.fill"         // 💵 Savings / Investment / Debt
    ]

    // ✨ Adaptive Grid
        let columns = [
            GridItem(.adaptive(minimum: 55), spacing: 20)
        ]

    var body: some View {
        ZStack {
            Color.cardBackground.ignoresSafeArea()

            VStack(spacing: 25) {
                Text(viewModel.selectedProject == nil ? "New Project" : "Edit Project")
                    .font(.customFont(family: .quicksand, name: .bold, size: .x20))
                    .foregroundStyle(Color.white)
                    .padding(.top, 20)

                // Name Input
                AppTextfield(inputText: $projectName, placeHolder: "Project Name (e.g. Dubai Trip)")
                    .frame(height: 50)
                // 2. Icon Grid (The Main Change 🎨)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select Icon")
                        .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                        .foregroundStyle(Color.gray)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                withAnimation(.spring()) {
                                    selectedIcon = icon
                                }
                            } label: {
                                ZStack {
                                    // Selected state mein Teal, warna transparent dark
                                    Circle()
                                        .fill(selectedIcon == icon ? Color.appPrimaryColor : Color.white.opacity(0.05))
                                        .frame(width: 55, height: 55)

                                    Image(systemName: icon)
                                        .foregroundStyle(selectedIcon == icon ? Color.black : Color.white)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                    }
                    .padding(15)
                    .background(Color.black.opacity(0.3)) // Grid ke peeche halka sa dark box
                    .cornerRadius(16)
                }
                // Spacer(minLength: 10)

                AppPrimaryButton(title: viewModel.selectedProject == nil ? "Create Project" : "Update Project",
                                 disable: .constant(projectName.isEmpty),
                                 isLoading: $viewModel.isDataUploading) {

                    if let _ = viewModel.selectedProject {
                        viewModel.updateProject(name: projectName, icon: selectedIcon)
                    } else {
                        viewModel.createProject(name: projectName, icon: selectedIcon)
                    }

                }.padding(.bottom, 20)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }.interactiveDismissDisabled(viewModel.isDataUploading)
        .onAppear {
            if let project = viewModel.selectedProject {
                projectName = project.name
                selectedIcon = project.icon
            }
        }
    }
}
