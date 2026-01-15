//
//  GoalsViewModel.swift
//  WhatIdo
//
//  Created by Cursor AI on 15/01/2026.
//

import Foundation

@MainActor
final class GoalsViewModel: BaseViewModel {
  @Published private(set) var goals: [Goal] = []
  @Published private(set) var isLoading: Bool = false
  @Published private(set) var errorMessage: String?

  private let goalsService: GoalsServiceProtocol

  init(goalsService: GoalsServiceProtocol) {
    self.goalsService = goalsService
    super.init()
  }

  func fetchGoals() {
    isLoading = true
    errorMessage = nil

    Task {
      let result = await goalsService.getGoals()
      switch result {
      case .data(let data):
        self.goals = data
      case .error(let message):
        self.errorMessage = message
        debugPrint("Failed to fetch goals: \(message)")
      default:
        break
      }
      self.isLoading = false
    }
  }
}

