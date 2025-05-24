//
//  BaseViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//

import SwiftUI
import Combine

class BaseViewModel: ObservableObject, Hashable {
    let id = UUID().uuidString
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    static func == (lhs: BaseViewModel, rhs: BaseViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
