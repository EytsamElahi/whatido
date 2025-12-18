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
    func postV2<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> T
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

    private func awaitCommittedSnapshot(_ ref: DocumentReference) async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            var listener: ListenerRegistration?

            listener = ref.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error = error {
                    listener?.remove()
                    continuation.resume(throwing: error)
                    return
                }
                guard let snapshot else { return }

                // ✅ only return when server has acked the write
                if snapshot.metadata.hasPendingWrites == false {
                    listener?.remove()
                    continuation.resume(returning: snapshot)
                }
            }
        }
    }

    func postV2<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> T {
        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }

        var dict: [String: Any] = [:]
        dict["created"] = FieldValue.serverTimestamp()
        dict["updated"] = FieldValue.serverTimestamp()

        dict.merge(data.asDictionary()) { _, new in new }

        try await ref.setData(dict, merge: true)

        let snap = try await awaitCommittedSnapshot(ref)

        guard snap.exists, let snapData = snap.data() else {
            throw FirestoreServiceError.documentNotFound
        }

        var parsed = try FirestoreParser.parse(snapData, type: T.self)
        if parsed.id.isEmpty { parsed.id = snap.documentID }
        return parsed
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

        var query: Query = ref.order(by: "created", descending: true)

        if let dateFilter = date {
            query = query.whereField(dateFilter.key, isGreaterThanOrEqualTo: Timestamp(date: dateFilter.from))
            query = query.whereField(dateFilter.key, isLessThanOrEqualTo: Timestamp(date: dateFilter.to))
        }
        // MARK: - if query param is passed
        if let params = queryParams {
            query = query.whereField(params.key, isEqualTo: params.value)
        }
        // First check it from cache
        var querySnapshot = try await query.getDocuments(source: .cache)
        if querySnapshot.documents.isEmpty {
            // If there are no document from cache check it from remote
            querySnapshot = try await query.getDocuments(source: .server)
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
    
    func request<T: FirestoreIdentifiable>(endpoint: FirestoreEndpoint) async throws -> T {
//        guard let ref = endpoint.path as? DocumentReference else {
//            throw FirestoreServiceError.documentNotFound
//        }
//        var document = try await ref.getDocument(source: .cache)
//        if document.exists == false {
//            document = try await ref.getDocument(source: .server)
//        }
//        guard let data = document.data() else {
//            throw FirestoreServiceError.documentNotFound
//        }

        guard let ref = endpoint.path as? DocumentReference else {
            throw FirestoreServiceError.documentNotFound
        }
        let document: DocumentSnapshot
        do {
            // Try cache first (fast)
            document = try await ref.getDocument(source: .cache)
        } catch {
            // Cache miss (or cache unavailable) -> try server
            do {
                document = try await ref.getDocument(source: .server)
            } catch {
                // If you're offline, server can fail too; .default will use cache if possible
                document = try await ref.getDocument(source: .default)
            }
        }
//        // If you're offline, server can fail too; .default will use cache if possible
//        document = try await ref.getDocument(source: .default)
        guard document.exists, let data = document.data() else {
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
