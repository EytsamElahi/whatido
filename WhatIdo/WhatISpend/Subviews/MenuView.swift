//
//  SortingView.swift
//  WhatIdo
//
//  Created by Eytsam Elahi on 22/05/2025.
//

import SwiftUI

struct MenuItem: Hashable {
    var id: Int
    var name: String
}
struct MenuView: View {
    var listing: [MenuItem]
    @State private var pickedItem: MenuItem = MenuItem(id: 0, name: "")
    var icon: String? = nil
    var text: String? = nil
    var rotation: Double? = nil
    var isPicker: Bool = false
    var action: (MenuItem) -> ()
    var body: some View {
        VStack {
            Menu {
                if isPicker {
                    // Picker inside a Menu to show options
                    Picker("Select an option", selection: $pickedItem) {
                        ForEach(listing, id: \.self) { option in
                            Text(option.name)
                                .foregroundStyle(Color.appPrimaryColor)
                                .font(.customFont(name: .regular, size: .x12))
                        }
                    }
                } else {
                    ForEach(listing, id: \.self) { option in
                        Button {
                            action(option)
                        } label: {
                            Text(option.name)
                                .foregroundStyle(Color.appPrimaryColor)
                                .font(.customFont(name: .regular, size: .x12))
                        }
                    }
                }
            } label: {
                HStack {
                    if let text = text {
                        Text(text)
                            .foregroundStyle(Color.appPrimaryColor)
                            .font(.customFont(name: .regular, size: .x14))
                    }
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundStyle(Color.primary)
                            .font(.title3)
                            .rotationEffect(.degrees(rotation ?? 0))
                    }
                }
            }.tint(.primary)
        }.onChange(of: pickedItem) { oldVal, newVal in
            debugPrint("New filter", newVal)
            action(newVal)
        }
    }
}
