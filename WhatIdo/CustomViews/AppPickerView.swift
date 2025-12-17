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

//struct CustomPickerView: View {
//    var listing: [String]
//    @Binding var pickedItem: String
//
//    var body: some View {
//        Menu {
//            // Picker inside a Menu to show options
//            Picker("Select an option", selection: $pickedItem) {
//                ForEach(listing, id: \.self) { option in
//                    Text(option)
//                }
//            }
//        } label: {
//            // Your custom view – triggers picker when tapped
//            HStack {
//                Text(pickedItem == "" ? "none" : pickedItem)
//                    .foregroundColor(.primary)
//                Spacer()
//                Image(systemName: "chevron.down")
//                    .foregroundColor(.appPrimaryColor)
//            }
//            .padding()
//            .background( RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray, lineWidth: 1))
//        }.foregroundColor(.primary)
//            .tint(.primary)
//    }
//}

struct CustomPickerView: View {
    var listing: [String]
    @Binding var pickedItem: String

    var maxFrequent: Int = 8

    @StateObject private var usage = PickerUsageStore()

    private var normalizedListing: [String] {
        listing
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var frequent: [String] {
        let sorted = normalizedListing
            .map { ($0, usage.count(for: $0)) }
            .filter { $0.1 > 0 }
            .sorted {
                if $0.1 != $1.1 { return $0.1 > $1.1 }
                return $0.0.localizedCaseInsensitiveCompare($1.0) == .orderedAscending
            }
            .map(\.0)

        // fallback for first-time user
        if sorted.isEmpty {
            return Array(normalizedListing.prefix(min(maxFrequent, normalizedListing.count)))
        }

        return Array(sorted.prefix(maxFrequent))
    }

    private var rest: [String] {
        let frequentSet = Set(frequent)
        return normalizedListing
            .filter { !frequentSet.contains($0) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        Menu {
            // "None" option if you want to allow clearing
            Button("none") {
                pickedItem = ""
            }

            if !frequent.isEmpty {
                Divider()
                // Frequent items right in the main menu
                ForEach(listing, id: \.self) { item in
                    Button(item) {
                        pickedItem = item
                        usage.record(item)
                    }
                }
            }

            if !rest.isEmpty {
                Divider()
                Menu("More") {
                    ForEach(rest, id: \.self) { option in
                        Button {
                            select(option)
                        } label: {
                            Text(option)
                        }
                    }
                }
            }

        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08)) // Dark fill

                HStack {
                    Text(pickedItem.isEmpty ? "Select" : pickedItem)
                        .font(.customFont(name: .medium, size: .x14))
                        .foregroundColor(pickedItem.isEmpty ? .white.opacity(0.3) : .white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appPrimaryColor) // Teal Chevron
                }
                .padding(.horizontal, 15)
            }
        }
//        .foregroundColor(.primary)
//        .tint(.primary)
    }

    private func select(_ option: String) {
        pickedItem = option
        usage.record(option)
    }

    @ViewBuilder
    private func labelFor(_ option: String) -> some View {
        // Optional: show a subtle checkmark for current selection
        HStack {
            Text(option)
            if pickedItem == option {
                Spacer()
                Image(systemName: "checkmark")
            }
        }
    }
}

