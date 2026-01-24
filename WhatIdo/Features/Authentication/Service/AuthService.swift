//
//  AuthService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import FirebaseAuth
import FirebaseFirestore

protocol AuthModelType {}
public struct AuthModel: AuthModelType {
    let userId: String
    let email: String?
    var name: String?
    var currency: String?

    func toUserDto() -> UserDto {
        return UserDto(id: userId, name: name, email: email, currency: currency)
    }
}


protocol AuthServiceProtocol {
    func signIn(with provider: AuthSocialProvider) async throws -> AuthModel
    func delete() async throws
    func logout() async throws
}

public final class FirebaseAuthService: AuthServiceProtocol, FirebaseService  {
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

    func delete() async throws {
        // 1. Check current user
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
      //  try await Firestore.firestore().clearPersistence()
       // try await deleteAllUserData(userId: user.uid)
        try await user.delete()
    }

    func logout() async throws {
       // try await Firestore.firestore().clearPersistence()
        try Auth.auth().signOut()
    }

}
