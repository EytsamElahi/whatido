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
                Text(spending.amount.toCurrency)
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

//#Preview {
//    SpendingRow(spending: SpendingDto(id: "", name: "", amount: 0.0, date: Date(), type: "", created: Date(),spendingTypeId: 0, spendingCategoryId: 0, fundSource: .cash))
//}

// MARK: - New Clean Row Design
struct UpdatedSpendingRow: View {
    let spending: SpendingDto
    var iconName: String { return spending.icon }
    var hideProject: Bool? = nil
    @EnvironmentObject var currencyManager: CurrencyManager

    var body: some View {
        HStack(spacing: 15) {
            // Icon Circle: Darker gray background with Teal Icon
            ZStack {
                Circle()
                    .fill(Color.cardBackground.opacity(1.0)) // Or slightly lighter: Color(hex: "2C2C2E")
                    .frame(width: 45, height: 45)
                    // Optional: Add thin border to make it pop
                    .overlay(
                        Circle().stroke(Color.appPrimaryColor.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: iconName)
                    .foregroundStyle(Color.appPrimaryColor)
                    .font(.system(size: 18))
            }

            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(spending.name)
                    .font(.customFont(family: .quicksand, name: .semiBold, size: .x16))
                    .foregroundStyle(Color.textPrimary) // ✅ White Text
                    .lineLimit(2) // ✅ Allow up to 2 lines
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.9) // ✅ Thora sa shrink allow karo taake fit ho jaye
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    Text(spending.type)
                    if let source = spending.fundSource?.rawValue {
                        Text("•")
                        Text(source)
                    }

                }
                .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                .foregroundStyle(Color.textSecondary) // ✅ Grey Text
                // Note: Assuming SpendingDto has optional `projectName`

                if let projName = spending.project?.projectName, !projName.isEmpty {
                    if hideProject == true {
                        EmptyView()
                    } else {
                        // Project Tag
                        HStack(spacing: 3) {
                            if let icon = spending.project?.projectIcon {
                                Image(systemName: icon)
                                    .font(.system(size: 8))
                            }
                            Text(projName)
                                .font(.customFont(family: .quicksand, name: .bold, size: .x10))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Color.appPrimaryColor) // Teal Color Pop
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appPrimaryColor.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()

            // Amount & Date
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(currencyManager.symbol ?? "") \(Int(spending.amount))")
                    .font(.customFont(family: .inter, name: .bold, size: .x16))
                    .foregroundStyle(Color.textPrimary) // ✅ White Text

                Text(spending.date.formatted(.dateTime.day().weekday()))
                    .font(.customFont(family: .quicksand, name: .medium, size: .x12))
                    .foregroundStyle(Color.textSecondary) // ✅ Grey Text
            }
        }
        .padding(15)
        .background(Color.cardBackground) // ✅ Dark Grey Card
        .cornerRadius(16)
        // Optional: Very subtle glow/shadow just to separate from black bg
        //.shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
