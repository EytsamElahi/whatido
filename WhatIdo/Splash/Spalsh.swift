//
//  Spalsh.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//


import SwiftUI

struct SplashView: View {
    @EnvironmentObject var navManager: NavigationManager
    // Inject Container
    let container: AppDependencyContainer
    var body: some View {
        NavigationStack(path: $navManager.path) {
            VStack {
                Text("What i do")
                    .font(.headline)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        navManager.push(screen: .spendings)
                    })
                }
                .navigationDestination(for: Route.self) { routes in
                        // MARK: - NAVIGATIONS
                        destinationView(for: routes)
                    }
        }
    }
}


// Helper to pass container down (Optional but recommended)
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: AppDependencyContainer = AppDependencyContainer()
}

extension EnvironmentValues {
    var dependencyContainer: AppDependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
