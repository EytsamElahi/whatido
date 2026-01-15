//
//  GoalsService.swift
//  WhatIdo
//
//  Created by Cursor AI on 15/01/2026.
//

import Foundation

protocol GoalsServiceProtocol {
  func getGoals() async -> AppResult<[Goal]>
}

final class GoalsService: FirebaseService, GoalsServiceProtocol {

  func getGoals() async -> AppResult<[Goal]> {
    do {
      let data: [Goal] = try await request(
        endpoint: FirestoreEndpoints.getAllGoals
      )
      return .data(data)
    } catch {
      return .error(error.localizedDescription)
    }
  }
}

