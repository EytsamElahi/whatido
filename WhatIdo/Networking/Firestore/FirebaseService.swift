//
//  FirebaseService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation
import FirebaseFirestore


protocol FirebaseService {
    func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws
    func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam?, endpoint: FirestoreEndpoint) async throws -> [T]
    func delete(endpoint: FirestoreEndpoint) async throws
}

extension FirebaseService {
    func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }
        let modelDict = data.asDictionary()
        try await ref.setData(modelDict)
    }

    func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam? = nil, endpoint: FirestoreEndpoint) async throws -> [T] {
        guard let ref = endpoint.path as? CollectionReference else {
            throw FirestoreServiceError.collectionNotFound
        }
//        if !Reachability.isConnectedToNetwork() {
//            throw FirestoreServiceError.noInternet
//        }
        var querySnapshot = try await ref.getDocuments()

        // MARK: - if query param is passed
        if let query = queryParams {
            querySnapshot = try await ref.whereField(query.key, isEqualTo: query.value).getDocuments()
        }
        var response: [T] = []
        for document in querySnapshot.documents {
            var data = try FirestoreParser.parse(document.data(), type: T.self)
            //If id is empty, assigning document id
            if data.id == "" {
                data.id = document.documentID
            }
            response.append(data)
        }
        return response
    }

    func delete(endpoint: FirestoreEndpoint) async throws {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.collectionNotFound
        }
        try await ref.delete()
    }
}
