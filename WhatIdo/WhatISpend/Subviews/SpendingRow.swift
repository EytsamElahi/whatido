//
//  SpendingRow.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI

struct SpendingRow: View {
    var spending: SpendingDto
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(spending.name)
                    .font(.customFont(name: .regular, size: .x18))
                Spacer()
                Text("Rs \(Int(spending.amount))")
                    .font(.customFont(name: .medium, size: .x18))
            }
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "tag.fill")
                    Text(spending.type)
                        .font(.customFont(name: .regular, size: .x16))
                    if let source = spending.fundSource?.rawValue {
                        Text("•") // Separator
                        Text(source) // Source
                            .font(.customFont(name: .regular, size: .x16))
                    }
                }
                Spacer()
                Text(spending.date.formatDateShort())
                    .font(.customFont(name: .regular, size: .x16))
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2) , radius: 2, x: 0, y: 0.5)
        }
    }
}

#Preview {
    SpendingRow(spending: SpendingDto(id: "", name: "", amount: 0.0, date: Date(), type: "", created: Date(),spendingTypeId: 0, spendingCategoryId: 0, fundSource: .cash))
}

// MARK: - New Clean Row Design
struct UpdatedSpendingRow: View {
    let spending: SpendingDto // Your Spending Model

    // Logic to choose icon based on category (Example)
    var iconName: String {
        // Replace with your actual category logic
        return "tag.fill"
    }

    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 45, height: 45)
                
                // Dynamic Icon yahan aa gaya
                Image(systemName: spending.icon)
                    .foregroundStyle(Color.black)
                // .foregroundStyle(spending.iconColor) // Agar icon colored chahiye
                    .font(.system(size: 18))
            }

            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(spending.name) // Title
                    .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(spending.type) // Category
                    if let source = spending.fundSource?.rawValue {
                        Text("•") // Separator
                        Text(source) // Source
                    }
                }
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                .foregroundStyle(Color.gray)
            }

            Spacer()

            // Amount & Date
            VStack(alignment: .trailing, spacing: 4) {
                Text("Rs \(Int(spending.amount))")
                    .font(.customFont(family: .inter, name: .bold, size: .x16))
                    .foregroundStyle(Color.primary)

                // Date formatter needed here
                Text(spending.date.formatted(.dateTime.day().weekday()))
                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(15)
        .background(Color(uiColor: .systemGray6)) // Light Grey Background
        .cornerRadius(16)
    }
}
