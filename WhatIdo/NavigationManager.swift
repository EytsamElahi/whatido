//
//  NavigationManager.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/05/2025.
//

import SwiftUI

final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum Route: Hashable {
    case detail(id: Int)
    case settings
}
