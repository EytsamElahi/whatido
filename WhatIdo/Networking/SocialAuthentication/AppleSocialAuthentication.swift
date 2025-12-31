//
//  AppleSocialAuthentication.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//
import Foundation
import FirebaseCore
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import Firebase

class AppleSocialAuthentication: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var signedIn: Bool = false
    var reauthenticate: Bool = false

    // Unhashed nonce.
    var currentNonce: String?

    override init() {
        super.init()
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.signedIn = true
                print("Auth state changed, is signed in")
            } else {
                self.signedIn = false
                print("Auth state changed, is signed out")
            }
        }
    }

    // MARK: - Password Account
    // Create, sign in, and sign out from password account functions...

    // MARK: - Apple sign in
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    // Single-sign-on with Apple
    @available(iOS 13, *)
    func startSignInWithAppleFlow(reauthenticated: Bool = false, completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        self.reauthenticate = reauthenticated
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()

        // Store the completion handler for later use
        self.signInCompletion = completion
    }

    private var signInCompletion: ((Result<AuthCredential, Error>) -> Void)?

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                self.signInCompletion?(.failure(SignInError.unableToFetchIdentityToken))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                self.signInCompletion?(.failure(SignInError.unableToSerializeToken))
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(providerID: .apple,
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            self.signInCompletion?(.success(credential))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
//        if !error.localizedDescription.contains("1001") {
//            self.signInCompletion?(.failure(error))
//        }
        self.signInCompletion?(.failure(error))
    }
}


// Extend AppleAuthentication to conform to ASAuthorizationControllerPresentationContextProviding
extension AppleSocialAuthentication: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchorr = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return anchorr
        }
        return ASPresentationAnchor()
    }
}
