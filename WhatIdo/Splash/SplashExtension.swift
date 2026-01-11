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
        case .spendings:
            SpendsListingView(viewModel: container.makeDashboardViewModel())
                .environment(\.dependencyContainer, container)
        case .SpendingDetails:
            EmptyView()
           // SpendingDetail(viewModel: viewModel)
        case .projectListing:
            ProjectsListingView(viewModel: container.makeProjectsViewModel())

        case .projectSpendingsList(let dto):
            ProjectSpendingsListView(project: dto, viewModel: container.makeProjectsViewModel())
                .environment(\.dependencyContainer, container)
        case .spendingAnalytics:
            AnalyticsView(viewModel: container.makeAnalyticsViewModel())
        case .currencySettings(let fromSettings):
            CurrencySettingsView(isFromSettings: fromSettings)
        case .login:
            AuthenticationView(viewModel: container.makeLoginViewModel())
        case .settings:
            SettingsView(viewModel: container.makeSettingsViewModel())
        }
    }
}
