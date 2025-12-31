//
//  AuthService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import FirebaseAuth

protocol AuthModelType {}
public struct AuthModel: AuthModelType {
    let userId: String
    let email: String?
    let name: String?
}


protocol AuthServiceProtocol {
    func signIn(with provider: AuthSocialProvider) async throws -> AuthModel
}

public final class FirebaseAuthService: AuthServiceProtocol  {
    private let socialAuthenticator: SocialAuthenticator

    public init( socialAuthenticator: SocialAuthenticator = SocialAuthenticator()) {
        self.socialAuthenticator = socialAuthenticator
    }

    func signIn(with provider: AuthSocialProvider) async throws -> AuthModel {
        let result = try await authenticate(with: provider)
        return map(result)
    }

    private func authenticate(with provider: AuthSocialProvider) async throws -> AuthDataResult {
        let authResult = try await socialAuthenticator.authenticate(
            with: provider
        )
        return authResult
    }

    private func map(_ result: AuthDataResult) -> AuthModel {
         let user = result.user
         return AuthModel(userId: user.uid, email: user.email, name: user.displayName)
     }

}
