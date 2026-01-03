//
//  UserRepository.swift
//  WhatIdo
//
//  Created by eytsam elahi on 01/01/2026.
//

protocol UserRepositoryType {
    func createUser(_ user: AuthModel) async -> AppResult<Void>
    func deleteUser(_ id: String)  async throws
    func getUser() -> AuthModel
    func editUser(_ user: AuthModel) async throws
}

class UserRepository: UserRepositoryType, FirebaseService {
    func createUser(_ user: AuthModel) async -> AppResult<Void> {
        let dUser = DUser(name: user.name, email: user.email)
        do {
            let endpoint = FirestoreEndpoints.addUser(id: user.userId)
            let data = try await post(data: dUser, endpoint: endpoint)
            return .success
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    func deleteUser(_ id: String) async throws { }

    func getUser() -> AuthModel {
        return AuthModel(userId: "", email: "", name: "")
    }
    
    func editUser(_ user: AuthModel) async throws { }


}
