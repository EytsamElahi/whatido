//
//  SpendingRow.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI

struct SpendingRow: View {
    var body: some View {
        HStack {
            Text("Milk")
                .font(.customFont(name: .regular, size: .x18))
            Spacer()
            Text("Rs 500")
                .font(.customFont(name: .medium, size: .x18))
        }.padding()
        .background {
            RoundedRectangle(cornerRadius: 10.0)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2) , radius: 2, x: 0, y: 0.5)
        }
    }
}

#Preview {
    SpendingRow()
}
