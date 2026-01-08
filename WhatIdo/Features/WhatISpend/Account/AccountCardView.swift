//
//  AccountCardView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import SwiftUI

struct AccountCardView: View {
    let account: AccountDto
    let brandColor = Color.appPrimaryColor
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onBalanceAdjustment: () -> Void
    var onMarkAsDefault: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#2c2c2e"), Color.black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Subtle Border
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            GeometryReader { proxy in
                Circle()
                    .fill(brandColor.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .offset(x: proxy.size.width - 80, y: -60)
                    .blur(radius: 30)
            }.clipShape(RoundedRectangle(cornerRadius: 24))

            // 3. CONTENT
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(account.name)
                                .font(.system(size: 18, weight: .bold)) // Readable Size
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            if account.isDefault {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(brandColor)
                                    .font(.caption)
                            }
                        }

                        // Type Badge (Bank/Cash)
                        Text(account.type.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundColor(brandColor) // Teal Color Text
                    }

                    Spacer()

                    // Optional: Contactless Icon (Subtle)
                    Image(systemName: "wave.3.right")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.title3)
                }

                Spacer()

                // --- BOTTOM ROW: Balance & Source Label ---
                HStack(alignment: .bottom) {

                    // Balance (Hero)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(CurrencyManager.shared.symbol)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.bottom, 2) // Thora alignment fix

                        Text("\(account.currentBalance, specifier: "%.0f")")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()
                    if let _ = account.sourceId {
                        Text(account.sourceName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 160)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                onBalanceAdjustment()
            } label: {
                Label("Adjust Balance", systemImage: "plus.forwardslash.minus")
            }
            if !account.isDefault {
                Button {
                    onMarkAsDefault()
                } label: {
                    Label("Set as Default", systemImage: "star.fill")
                }
            }
        }
    }
}

#Preview {
    AccountCardView(account: AccountDto(id: "", name: "Meezan Bank", type: .bank, openingBalance: 20000, currentBalance: 200000, currency: "PKR", sourceId: "", isArchived: false, createdAt: nil, isDefault: true), onEdit: {}, onDelete: {}, onBalanceAdjustment: {}, onMarkAsDefault: {})
}
