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
                HStack {
                    Image(systemName: "tag.fill")
                    Text(spending.type)
                        .font(.customFont(name: .regular, size: .x16))
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
    SpendingRow(spending: SpendingDto(id: "", name: "", amount: 0.0, date: Date(), type: "", created: Date()) )
}
