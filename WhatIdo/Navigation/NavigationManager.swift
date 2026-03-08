//
//  NavigationManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import SwiftUI

@MainActor
final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()

     func push(screen: Route) {
        // Defer navigation to next run loop to prevent multiple updates per frame
        DispatchQueue.main.async { [weak self] in
            self?.path.append(screen)
        }
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot(index: Int) {
        path.removeLast( path.count - index)
    }

    func popViews(_ numberOfViews: Int) {
        path.removeLast(numberOfViews)
    }
}
