//
//  ProjectCard.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import SwiftUI
// A simple card for the project
struct ProjectCard: View {
    let project: ProjectDto

    var body: some View {
        HStack {
            ZStack {
                Circle().fill(Color.appPrimaryColor.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: project.icon).foregroundStyle(Color.appPrimaryColor)
            }

            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.customFont(family: .quicksand, name: .bold, size: .x18))
                    .foregroundStyle(Color.white)

                Text("Tap to view details")
                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                    .foregroundStyle(Color.gray)
            }
            Spacer()

            // Total Spent Calculation (ViewModel se ayega)
            Text("Rs 50k")
                .font(.customFont(family: .inter, name: .bold, size: .x16))
                .foregroundStyle(Color.white)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
