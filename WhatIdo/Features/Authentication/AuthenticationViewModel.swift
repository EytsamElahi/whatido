//
//  AuthenticationViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import Foundation
import UserNotifications

@MainActor
class AuthenticationViewModel: ObservableObject {
  private let authService: AuthServiceProtocol
  private let userRepo: UserRepositoryType
  private let analytics = AnalyticsManager.shared
  @Published var showUsernameSheet: Bool = false
  @Published var isAuthenticating: Bool = false
  private var user: AuthModel?
  private let overlayManager = OverlayManager.shared
  @Published var navigateToCurrency: Bool = false
  @Published var navigateToDashboard: Bool = false

  init(authService: AuthServiceProtocol, userRepo: UserRepositoryType = UserRepository()) {
    self.authService = authService
    self.userRepo = userRepo
  }

  private func checkNotificationAuthorizationStatus() async -> Bool {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    return settings.authorizationStatus == .authorized
  }

  func authenticate(_ provider: AuthSocialProvider) {
    Task { [weak self] in
      guard let self = self else { return }
      do {
        self.isAuthenticating = true
        let user = try await authService.signIn(with: provider)
        self.user = user
        self.overlayManager.showLoader()
        let result = await userRepo.getUser(id: user.userId)
        if case .data(let dUser) = result {
          await handleExistingUser(dUser, userId: user.userId)
        } else {
          handleNewUser(user, provider: provider)
        }
      } catch {
        self.isAuthenticating = false
        self.overlayManager.hideLoader()
        self.overlayManager.showToast(message: error.localizedDescription, style: .error)
      }
    }
  }

  private func handleExistingUser(_ dUser: DUser, userId: String) async {
    user?.name = dUser.name
    user?.currency = dUser.currency
    AppData.user = dUser.toUserDto()
    let _ = await userRepo.updateFCMToken(userId: userId, token: AppData.fcmToken)
    overlayManager.hideLoader()
    if let currencyCode = dUser.currency {
      CurrencyManager.shared.setCurrencyBySymbol(currencyCode)
      overlayManager.showToast(message: "Welcome back!", style: .success)
      navigateToDashboard = true
    } else {
      overlayManager.showToast(message: "Please select your preferred currency", style: .success)
      navigateToCurrency = true
    }
  }

  private func handleNewUser(_ user: AuthModel, provider: AuthSocialProvider) {
    analytics.logUserSignup(provider: provider.rawValue)
    overlayManager.hideLoader()
    if user.name == nil {
      showUsernameSheet = true
    } else {
      createUserProfile()
    }
  }

  func setUserName(username: String) {
    showUsernameSheet = false
    if username == "" {
      createUserProfile()
      return
    }
    self.user?.name = username
    createUserProfile()
  }

  private func createUserProfile() {
    guard let user = user else { return }
    Task { [weak self] in
      guard let self = self else { return }
      overlayManager.showLoader()
      defer {
        overlayManager.hideLoader()
      }
      let result = await userRepo.createUser(user, currency: nil)
      if case .error(let string) = result {
        self.overlayManager.showToast(message: string, style: .error)
        return
      }

      let notificationEnabled = await checkNotificationAuthorizationStatus()
      var userDto = user.toUserDto()
      userDto.enableNotification = notificationEnabled
      AppData.user = userDto
      self.overlayManager.showToast(message: "Profile Created", style: .success)
      navigateToCurrency = true
    }
  }
}
