//
//  AppPickerView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import SwiftUI

struct AppPickerView: View {
    var colors = ["Red", "Green", "Blue", "Tartan"]
    @State private var selectedColor = "Red"
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
                    Picker("Please choose a color", selection: $selectedColor) {
                        ForEach(colors, id: \.self) {
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
    AppPickerView()
}
