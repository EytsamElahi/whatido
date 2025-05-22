//
//  SortingView.swift
//  WhatIdo
//
//  Created by Eytsam Elahi on 22/05/2025.
//

import SwiftUI

struct FilterLevel: Hashable {
    var id: Int
    var name: String
}
struct SortingView: View {
    var listing: [FilterLevel]
    @Binding var pickedItem: FilterLevel
    var body: some View {
        Menu {
            // Picker inside a Menu to show options
            Picker("Select an option", selection: $pickedItem) {
                ForEach(listing, id: \.self) { option in
                    Text(option.name)
                }
            }
        } label: {
            HStack {
                Text("Sort by")
                    .foregroundStyle(Color.appPrimaryColor)
                    .font(.customFont(name: .regular, size: .x14))
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(Color.primary)
                    .font(.title3)
            }
        }.tint(.primary)
    }
}
