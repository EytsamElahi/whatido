//
//  AuthenticationViewModel.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import Foundation

@MainActor
class AuthenticationViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let userRepo: UserRepositoryType
    @Published var showUsernameSheet: Bool = false
    private var user: AuthModel?
    private let overlayManager = OverlayManager.shared
    @Published var navigateToCurrency: Bool = false
    @Published var navigateToDashboard: Bool = false
    
    init(authService: AuthServiceProtocol, userRepo: UserRepositoryType = UserRepository()) {
        self.authService = authService
        self.userRepo =  userRepo
    }

    func authenticate(_ provider: AuthSocialProvider) {
        Task { [weak self] in
            guard let self = self else {return}
            do {
                let user = try await authService.signIn(with: provider)
                self.user = user
                
                // 1. Check if user already exists in Firestore
                let result = await userRepo.getUser(id: user.userId)
                
                if case .data(let dUser) = result {
                    // User already exists!
                    self.user?.name = dUser.name
                    self.user?.currency = dUser.currency
                    
                    // Populate AppData and CurrencyManager
                    AppData.user = self.user?.toUserDto()
                    if let currencyCode = dUser.currency {
                        CurrencyManager.shared.setCurrencyBySymbol(currencyCode)
                        self.overlayManager.showToast(message: "Welcome back!", style: .success)
                        self.navigateToDashboard = true
                    } else {
                        // User exists but no currency preference saved
                        self.overlayManager.showToast(message: "Please select your preferred currency", style: .success)
                        self.navigateToCurrency = true
                    }
                } else {
                    // New User
                    if user.name == nil {
                        self.showUsernameSheet = true
                    } else {
                        createUserProfile()
                    }
                }
            } catch {
                self.overlayManager.showToast(message: error.localizedDescription, style: .error)
            }
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
        guard let user = user else {return}
        Task {[weak self] in
            guard let self = self else {return}
            overlayManager.showLoader()
            defer {
                overlayManager.hideLoader()
            }
            let result = await userRepo.createUser(user, currency: nil)
            if case .error(let string) = result {
                self.overlayManager.showToast(message: string, style: .error)
                return
            }

            AppData.user = user.toUserDto()
            self.overlayManager.showToast(message: "Profile Created", style: .success)
            navigateToCurrency = true
        }

    }
}
