//
//  SplashExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/05/2025.
//


import Foundation
import SwiftUI

extension SplashView {
    @ViewBuilder
    func destinationView(for route: Route) -> some View {
        switch route {
        case .spendings(let spendingsViewModel):
            SpendsListingView(viewModel: spendingsViewModel)
        case .SpendingDetails(let viewModel):
            SpendingDetail(viewModel: viewModel)
        }
    }
}
