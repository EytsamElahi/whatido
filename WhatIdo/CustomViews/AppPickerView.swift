//
//  AppPickerView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import SwiftUI

struct AppPickerView: View {
    var listing: [String]
    @Binding var pickedItem: String
    var body: some View {
        ZStack(content: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
            VStack {
                HStack {
                    Text("Pick category")
                        .foregroundStyle(Color.black)
                        .font(.customFont(name: .medium, size: .x16))
                    Spacer()
                    Picker("Please choose a color", selection: $pickedItem) {
                        ForEach(listing, id: \.self) {
                            Text($0)
                                .foregroundStyle(Color.black)
                                .font(.customFont(name: .medium, size: .x16))
                        }
                    }.tint(.black)
                }.padding(10)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
           // .padding(10)
        })
    }
}

#Preview {
    AppPickerView(listing: [], pickedItem: .constant(""))
}

struct CustomPickerView: View {
    var listing: [String]
    @Binding var pickedItem: String

    var body: some View {
        Menu {
            // Picker inside a Menu to show options
            Picker("Select an option", selection: $pickedItem) {
                ForEach(listing, id: \.self) { option in
                    Text(option)
                }
            }
        } label: {
            // Your custom view – triggers picker when tapped
            HStack {
                Text(pickedItem == "" ? "none" : pickedItem)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.appPrimaryColor)
            }
            .padding()
            .background( RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1))
        }.foregroundColor(.primary)
            .tint(.primary)
    }
}
