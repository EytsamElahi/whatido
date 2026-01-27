//
//  UserRepository.swift
//  WhatIdo
//
//  Created by eytsam elahi on 01/01/2026.
//

protocol UserRepositoryType {
    func createUser(_ user: AuthModel, currency: String?) async -> AppResult<Void>
    func deleteUser(_ id: String)  async throws
    func getUser(id: String) async -> AppResult<DUser>
    func editUser(_ user: DUser) async throws
    func updateUserCurrency(userId: String, currency: String) async -> AppResult<Void>
    func updateFCMToken(userId: String, token: String?) async -> AppResult<Void>
}

class UserRepository: UserRepositoryType, FirebaseService {
    func createUser(_ user: AuthModel, currency: String?) async -> AppResult<Void> {
        let dUser = DUser(name: user.name, email: user.email, currency: currency, fcmToken: AppData.fcmToken)
        do {
            let endpoint = FirestoreEndpoints.addUser(id: user.userId)
            let _ = try await post(data: dUser, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func deleteUser(_ id: String) async throws { }

    func getUser(id: String) async -> AppResult<DUser> {
        do {
            let endpoint = FirestoreEndpoints.addUser(id: id)
            let user: DUser = try await request(endpoint: endpoint)
            return .data(user)
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func editUser(_ user: DUser) async throws {
        let endpoint = FirestoreEndpoints.editUser(id: user.id)
        try await update(data: user, endpoint: endpoint)
    }

    func updateUserCurrency(userId: String, currency: String) async -> AppResult<Void> {
        do {
            let endpoint = FirestoreEndpoints.editUser(id: userId)
            // We can fetch first or just post partial if our FirebaseService supports it.
            // Since post with merge: true is available, we use that.
            let dUser = DUser(name: nil, email: nil, currency: currency, fcmToken: nil)
            dUser.id = userId
            let _ = try await post(data: dUser, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    func updateFCMToken(userId: String, token: String?) async -> AppResult<Void> {
        do {
            let endpoint = FirestoreEndpoints.editUser(id: userId)
            let dUser = DUser(name: nil, email: nil, currency: nil, fcmToken: token)
            dUser.id = userId
            let _ = try await post(data: dUser, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }

}
