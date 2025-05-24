//
//  NavigationManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import SwiftUI

final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()

     func push(screen: Route) {
        path.append(screen)
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
