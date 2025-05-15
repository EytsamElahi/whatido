//
//  SpendsListingView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import SwiftUI

struct SpendsListingView: View {
    @State var showSheet: Bool = false
    @EnvironmentObject var navigation: NavigationManager
    @StateObject var viewModel = SpendingsViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Spendings")
                            .font(.customFont(name: .medium, size: .x18))
                        Text("Rs5000")
                            .font(.customFont(name: .bold, size: .x30))
                    }
                    Spacer()
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }.padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2) , radius: 2, x: 0, y: 0.5)
                    }.padding()
                ScrollView {
                    ForEach(viewModel.spendings ?? [], id: \.self) { spending in
                        SpendingRow(spending: spending)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                    }
                }
                Spacer()
            }
        }.onAppear(perform: {
            viewModel.fetchSpendings()
        })
        .sheet(isPresented: $showSheet) {
            AddSpendingView()
                .environmentObject(viewModel)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    SpendsListingView()
}
