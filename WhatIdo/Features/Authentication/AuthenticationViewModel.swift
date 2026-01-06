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
                if user.name == nil {
                    self.showUsernameSheet = true
                } else {
                    createUserProfile()
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
            let result = await userRepo.createUser(user)
            if case .error(let string) = result {
                self.overlayManager.showToast(message: string, style: .error)
                return
            }

            AppData.user = user.toUserDto()
            self.overlayManager.showToast(message: "User Authenticated Successfully", style: .success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.navigateToCurrency = true
            }
        }

    }
}
