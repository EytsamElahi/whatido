//
//  Spalsh.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//


import SwiftUI

struct SplashView: View {
    @EnvironmentObject var navManager: NavigationManager
    var body: some View {
        NavigationStack(path: $navManager.path) {
            VStack {
                Text("What i do")
                    .font(.headline)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        navManager.push(screen: .spendings(SpendingsViewModel(spendingService: WhatISpendService())))
                    })
                }
                .navigationDestination(for: Route.self) { routes in
                        // MARK: - NAVIGATIONS
                        destinationView(for: routes)
                    }
        }
    }
}
