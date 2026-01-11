//
//  SocialAuthenticator.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//


import Foundation
import FirebaseAuth

public final class SocialAuthenticator {
    public init() {}
    
    public func authenticate(
        with type: AuthSocialProvider
    ) async throws -> AuthDataResult {
        let authCred: AuthCredential? = try await getAuthCreds(type: type)
        guard let authCred = authCred else {
            throw NSError(domain: "AuthFeature",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing credential"])
        }
        let result = try await Auth.auth().signIn(with: authCred)
        return result
    }

    private func mapSocialProviderDto(_ methods: [String]) -> [AuthSocialProvider] {
        var providers: [AuthSocialProvider] = []
        if methods.contains("google.com")        { providers.append(.google) }
        if methods.contains("apple.com")         { providers.append(.apple) }
        return providers
    }

    private func getAuthCreds(type: AuthSocialProvider) async throws -> AuthCredential? {
        switch type {
        case .google:
            return try await googleAuthentication()
        case .apple:
            return try await appleAuthentication()
        default:
           return nil
        }
    }

    private func googleAuthentication() async throws -> AuthCredential {
        try await GoogleAuthentication().performGoogleAuthentication()
    }

    private func appleAuthentication() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                let appleAuth = AppleSocialAuthentication()
                appleAuth.startSignInWithAppleFlow { response in
                    switch response {
                    case .success(let cred):
                        continuation.resume(returning: cred)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
