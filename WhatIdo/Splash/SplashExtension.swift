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
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel())
        case .spendings:
            SpendsListingView(viewModel: container.makeDashboardViewModel())
        case .SpendingDetails:
            EmptyView()
           // SpendingDetail(viewModel: viewModel)
        case .projectListing:
            ProjectsListingView(viewModel: container.makeProjectsViewModel())

        case .projectSpendingsList(let dto):
            ProjectSpendingsListView(project: dto, viewModel: container.makeProjectsViewModel())
        case .spendingAnalytics:
             AnalyticsView(viewModel: container.makeAnalyticsViewModel())
        case .currencySettings(let fromSettings):
            CurrencySettingsView(viewModel: container.makeCurrencySettingsViewModel(), isFromSettings: fromSettings)
        case .login:
            AuthenticationView(viewModel: container.makeLoginViewModel())
        case .settings:
            SettingsView(viewModel: container.makeSettingsViewModel())
        case .goals:
            GoalsView(viewModel: container.makeGoalsViewModel())
        }
    }
}
