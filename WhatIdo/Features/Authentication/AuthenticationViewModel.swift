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

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func authenticate(_ provider: AuthSocialProvider) {
        Task { [weak self] in
            guard let self = self else {return}
            do {
                let user = try await authService.signIn(with: provider)
                debugPrint(user)
            } catch {

            }
        }
    }
}
