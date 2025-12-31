//
//  GoogleAuthentication.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

/// A class responsible for handling Google authentication within a Firebase-integrated iOS application.
class GoogleAuthentication {

    /// Performs Google OAuth authentication and returns an `AuthDataResult` upon successful sign-in.
        ///
        /// - Throws: An error if authentication fails or if the Firebase client ID is missing.
        /// - Returns: `AuthDataResult` containing user authentication details.
    func performGoogleOauth() async throws -> AuthDataResult {
        let credential = try await performGoogleAuthentication()
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult
     }

    @MainActor
    func performGoogleAuthentication() async throws -> AuthCredential {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase clientID found")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let rootViewController = try await getRootViewController()
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw SignInError.unableToSerializeToken
        }

        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
    }


    func googleLogout() async throws {
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance.signOut()
        }
        try Auth.auth().signOut()
    }

    private func getRootViewController() async throws -> UIViewController {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = scene.windows.first?.rootViewController else {
                    continuation.resume(throwing: "There is no root view controller!")
                    return
                }
                continuation.resume(returning: rootViewController)
            }
        }
    }
    /// Initiates the Google sign-in process using the provided root view controller.
    private func signInWithGoogle(using rootViewController: UIViewController) async throws -> GIDSignInResult {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {  // Ensure UI code runs on the main thread
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        if !error.localizedDescription.contains("canceled") {
                            continuation.resume(throwing: error)
                        }
                    } else if let result = result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: "Google sign-in failed")
                    }
                }
            }
        }
    }
}
extension String: @retroactive Error {}
enum SignInError: Error {
    case unableToFetchIdentityToken
    case unableToSerializeToken
}
