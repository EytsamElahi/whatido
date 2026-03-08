//
//  GoalsViewModelTests.swift
//  WhatIdoTests
//
//  Created by Cursor AI on 15/01/2026.
//

import XCTest
@testable import WhatIdo

@MainActor
final class GoalsViewModelTests: XCTestCase {

  // MARK: - Mocks

  final class MockGoalsService: GoalsServiceProtocol {
    var resultToReturn: AppResult<[Goal]> = .data([])
    private(set) var getGoalsCalledCount: Int = 0

    func getGoals() async -> AppResult<[Goal]> {
      getGoalsCalledCount += 1
      return resultToReturn
    }
  }

  // MARK: - Helpers

  private func makeSUT(
    result: AppResult<[Goal]>
  ) -> (GoalsViewModel, MockGoalsService) {
    let service = MockGoalsService()
    service.resultToReturn = result
    let viewModel = GoalsViewModel(goalsService: service)
    return (viewModel, service)
  }

  // MARK: - Tests

  func test_fetchGoals_success_populatesGoalsAndClearsError() async throws {
    // Given
    let goal1 = Goal(title: "Save for laptop", targetDate: Date().addingTimeInterval(86400))
    let goal2 = Goal(title: "Pay off credit card", targetDate: Date().addingTimeInterval(86400 * 7))
    let (sut, service) = makeSUT(result: .data([goal1, goal2]))

    // When
    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)

    // Then
    XCTAssertEqual(service.getGoalsCalledCount, 1)
    XCTAssertFalse(sut.isLoading)
    XCTAssertNil(sut.errorMessage)
    XCTAssertEqual(sut.goals.count, 2)
    XCTAssertEqual(sut.goals.first?.title, "Save for laptop")
  }

  func test_fetchGoals_error_setsErrorMessageAndKeepsGoalsEmpty() async throws {
    // Given
    let (sut, _) = makeSUT(result: .error("Network error"))

    // When
    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)

    // Then
    XCTAssertFalse(sut.isLoading)
    XCTAssertTrue(sut.goals.isEmpty)
    XCTAssertEqual(sut.errorMessage, "Network error")
  }

  func test_fetchGoals_clearsPreviousErrorOnNewLoad() async throws {
    // Given
    let (sut, service) = makeSUT(result: .data([]))

    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)
    XCTAssertNil(sut.errorMessage)

    // Simulate an error on next fetch
    service.resultToReturn = .error("Something went wrong")

    // When
    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)

    // Then
    XCTAssertFalse(sut.isLoading)
    XCTAssertTrue(sut.goals.isEmpty)
    XCTAssertEqual(sut.errorMessage, "Something went wrong")
  }

  func test_fetchGoals_setsLoadingStateDuringRequest() async throws {
    // Given a slow mock service
    final class SlowMockGoalsService: GoalsServiceProtocol {
      func getGoals() async -> AppResult<[Goal]> {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .data([])
      }
    }

    let sut = GoalsViewModel(goalsService: SlowMockGoalsService())

    // When
    sut.fetchGoals()

    // Immediately after calling, loading should be true
    XCTAssertTrue(sut.isLoading)

    // Wait for completion
    try await Task.sleep(nanoseconds: 250_000_000)

    // Then
    XCTAssertFalse(sut.isLoading)
  }

  func test_fetchGoals_handlesEmptyListGracefully() async throws {
    // Given
    let (sut, _) = makeSUT(result: .data([]))

    // When
    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)

    // Then
    XCTAssertFalse(sut.isLoading)
    XCTAssertTrue(sut.goals.isEmpty)
    XCTAssertNil(sut.errorMessage)
  }

  func test_multipleFetches_overwriteExistingGoals() async throws {
    // Given
    let (sut, service) = makeSUT(
      result: .data([Goal(title: "First", targetDate: Date())])
    )

    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)
    XCTAssertEqual(sut.goals.count, 1)

    // When - new data second time
    let newGoal = Goal(title: "Second", targetDate: Date())
    service.resultToReturn = .data([newGoal])

    sut.fetchGoals()
    try await Task.sleep(nanoseconds: 150_000_000)

    // Then
    XCTAssertEqual(sut.goals.count, 1)
    XCTAssertEqual(sut.goals.first?.title, "Second")
  }
}

