//
//  FirebaseService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation
import FirebaseFirestore


protocol FirebaseService {
    @discardableResult
    func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> String
    func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam?, filter date: FirestoreDateFilter?, endpoint: FirestoreEndpoint) async throws -> [T]
    func request<T: FirestoreIdentifiable>(endpoint: FirestoreEndpoint) async throws -> T
    func delete(endpoint: FirestoreEndpoint) async throws
    func update<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws
}

extension FirebaseService {
    @discardableResult
    func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> String {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }
        debugPrint("New document id:",ref.documentID)
        var dict: [String: Any] = [
            "created": Timestamp(date: Date()),
            "updated": Timestamp(date: Date()),
        ]
        let modelDict = data.asDictionary()
        dict.merge(modelDict) { (_, new) in new }
        try await ref.setData(dict)
        return ref.documentID
    }
    func update<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }
        var dict: [String: Any] = [
            "updated": Timestamp(date: Date()),
        ]
        let modelDict = data.asDictionary()
        dict.merge(modelDict) { (_, new) in new }
        try await ref.setData(dict)
    }

    func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam? = nil, filter date: FirestoreDateFilter? = nil, endpoint: FirestoreEndpoint) async throws -> [T] {
        guard let ref = endpoint.path as? CollectionReference else {
            throw FirestoreServiceError.collectionNotFound
        }
//        if !Reachability.isConnectedToNetwork() {
//            throw FirestoreServiceError.noInternet
//        }
        var query: Query = ref.order(by: "date", descending: true)

        if let dateFilter = date {
            query = query.whereField(dateFilter.key, isGreaterThanOrEqualTo: Timestamp(date: dateFilter.from))
            query = query.whereField(dateFilter.key, isLessThanOrEqualTo: Timestamp(date: dateFilter.to))
        }
        // MARK: - if query param is passed
        if let params = queryParams {
            query = query.whereField(params.key, isEqualTo: params.value)
        }
        let querySnapshot = try await query.getDocuments()
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
    
    func request<T: FirestoreIdentifiable>(endpoint: FirestoreEndpoint) async throws -> T {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }
        let document =  try await ref.getDocument()
        guard let data = document.data() else {
            throw FirestoreServiceError.documentNotFound
        }
        var parsedData = try FirestoreParser.parse(data, type: T.self)
        if parsedData.id == "" {
            parsedData.id = document.documentID
        }
        return parsedData
    }

    func delete(endpoint: FirestoreEndpoint) async throws {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.collectionNotFound
        }
        try await ref.delete()
    }
}
