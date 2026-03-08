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
  func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam?, filter date: FirestoreDateFilter?, orderBy: String?, endpoint: FirestoreEndpoint) async throws -> [T]
  func request<T: FirestoreIdentifiable>(endpoint: FirestoreEndpoint) async throws -> T
  func delete(endpoint: FirestoreEndpoint) async throws
  func update<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws
  func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> T
  func deleteAtomic(documentEndpoint: FirestoreEndpoint, dependentCollectionEndpoint: FirestoreEndpoint, dependencyParam: FirestoreQueryParam) async throws
  func updateCollectionProperties(_ queryParam: FirestoreQueryParam, endpoint: FirestoreEndpoint) async throws
  func postWithAtomicUpdate<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint, atomicUpdates: [DocumentReference: [String: Any]]) async throws -> T
  func performBatchUpdate(instructions: [(endpoint: FirestoreEndpoint, params: [FirestoreQueryParam])]) async throws
  func deleteAllUserData(userId: String) async throws
  func streamRequest<T: FirestoreIdentifiable>(
    _ queryParams: FirestoreQueryParam?,
    filter date: FirestoreDateFilter?,
    orderBy: String?,
    endpoint: FirestoreEndpoint
  ) -> AsyncThrowingStream<[T], Error>
}

extension FirebaseService {

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

        // only return when server has acked the write
        if snapshot.metadata.hasPendingWrites == false {
          listener?.remove()
          continuation.resume(returning: snapshot)
        }
      }
    }
  }

  func post<T: FirestoreIdentifiable>(data: T, endpoint: FirestoreEndpoint) async throws -> T {
    guard let ref = endpoint.path as? DocumentReference else {
      throw FirestoreServiceError.documentNotFound
    }

    // 1. Prepare Data
    var dict: [String: Any] = [:]
    dict["created"] = FieldValue.serverTimestamp()
    dict["updated"] = FieldValue.serverTimestamp()
    dict.merge(data.asDictionary()) { _, new in new }

    ref.setData(dict, merge: true) { _ in }

    // 3. Return Optimistic Data Immediately
    var optimisticData = data
    if optimisticData.id.isEmpty {
      optimisticData.id = ref.documentID
    }

    return optimisticData
  }

  // Generic logic for future use
  func postWithAtomicUpdate<T: FirestoreIdentifiable>(
    data: T,
    endpoint: FirestoreEndpoint,
    atomicUpdates: [DocumentReference: [String: Any]] // Side effects (e.g. Balance Update)
  ) async throws -> T {

    guard let mainRef = endpoint.path as? DocumentReference else {
      throw FirestoreServiceError.documentNotFound
    }

    let batch = mainRef.firestore.batch()

    // 1. Prepare Main Document Data
    var dict = data.asDictionary()
    dict["created"] = FieldValue.serverTimestamp()
    dict["updated"] = FieldValue.serverTimestamp()

    // Set main data in batch
    batch.setData(dict, forDocument: mainRef, merge: true)

    // 2. Apply Atomic Side Effects (Balance Updates, etc.)
    for (ref, fields) in atomicUpdates {
      batch.updateData(fields, forDocument: ref)
    }

    // 3. Commit Batch
    try await batch.commit()

    // 4. Reuse your logic to get the snapshot and parse
    let snap = try await awaitCommittedSnapshot(mainRef)

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
    try await ref.setData(dict, merge: true)
  }

  func request<T: FirestoreIdentifiable>(_ queryParams: FirestoreQueryParam? = nil, filter date: FirestoreDateFilter? = nil, orderBy: String? = nil, endpoint: FirestoreEndpoint) async throws -> [T] {
    guard let ref = endpoint.path as? CollectionReference else {
      throw FirestoreServiceError.collectionNotFound
    }

    var query: Query = ref.order(by: orderBy ?? "date", descending: true)
    if let dateFilter = date {
      query = query.whereField(dateFilter.key, isGreaterThanOrEqualTo: Timestamp(date: dateFilter.from))
      query = query.whereField(dateFilter.key, isLessThanOrEqualTo: Timestamp(date: dateFilter.to))
    }
    // MARK: - if query param is passed
    if let params = queryParams {
      query = query.whereField(params.key, isEqualTo: params.value)
    }
    query = query.whereField("userId", isEqualTo: AppData.user?.id ?? "")
    var querySnapshot = try await query.getDocuments(source: .default)
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

  func streamRequest<T: FirestoreIdentifiable>(
    _ queryParams: FirestoreQueryParam? = nil,
    filter date: FirestoreDateFilter? = nil,
    orderBy: String? = nil,
    endpoint: FirestoreEndpoint
  ) -> AsyncThrowingStream<[T], Error> {

    return AsyncThrowingStream { continuation in
      guard let ref = endpoint.path as? CollectionReference else {
        continuation.finish(throwing: FirestoreServiceError.collectionNotFound)
        return
      }

      var query: Query = ref.order(by: orderBy ?? "date", descending: true)
      if let dateFilter = date {
        query = query.whereField(dateFilter.key, isGreaterThanOrEqualTo: Timestamp(date: dateFilter.from))
        query = query.whereField(dateFilter.key, isLessThanOrEqualTo: Timestamp(date: dateFilter.to))
      }
      if let params = queryParams {
        query = query.whereField(params.key, isEqualTo: params.value)
      }
      query = query.whereField("userId", isEqualTo: AppData.user?.id ?? "")
      let listener = query.addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
        if let error = error {
          continuation.finish(throwing: error)
          return
        }

        guard let snapshot = snapshot else { return }

        let items: [T] = snapshot.documents.compactMap { document in
          var item = try? FirestoreParser.parse(document.data(), type: T.self)
          if item?.id == "" { item?.id = document.documentID }
          return item
        }

        // Yield the data to the UI
        continuation.yield(items)
      }

      // Clean up the listener when the View disappears or Task is cancelled
      continuation.onTermination = { @Sendable _ in
        listener.remove()
      }
    }
  }

  func request<T: FirestoreIdentifiable>(endpoint: FirestoreEndpoint) async throws -> T {

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

  func deleteAtomic(documentEndpoint: FirestoreEndpoint, dependentCollectionEndpoint: FirestoreEndpoint, dependencyParam: FirestoreQueryParam) async throws {

    // 1. Parent Document Reference (e.g., Project)
    guard let docRef = documentEndpoint.path as? DocumentReference else {
      throw FirestoreServiceError.documentNotFound
    }

    // 2. Child Collection Reference (e.g., Spendings)
    guard let colRef = dependentCollectionEndpoint.path as? CollectionReference else {
      throw FirestoreServiceError.collectionNotFound
    }

    // 3. Query to find children (e.g., spendings where projectId == xyz)
    var query = colRef.whereField(dependencyParam.key, isEqualTo: dependencyParam.value)
    query = query.whereField("userId", isEqualTo: AppData.user?.id ?? "")

    // 4. Fetch snapshots (Network call)
    let snapshot = try await query.getDocuments()

    // 5. Initialize Batch
    let batch = docRef.firestore.batch()

    // 6. Add all children to delete batch
    // NOTE: Firestore batch limit is 500 operations.
    for document in snapshot.documents {
      batch.deleteDocument(document.reference)
    }

    // 7. Add parent document to delete batch
    batch.deleteDocument(docRef)

    // 8. Commit Atomic Write
    try await batch.commit()
  }

  func updateCollectionProperties(_ queryParam: FirestoreQueryParam, endpoint: FirestoreEndpoint) async throws {
    guard let ref = endpoint.path as? DocumentReference else {
      throw FirestoreServiceError.documentNotFound
    }
    try await ref.updateData([
      queryParam.key: queryParam.value,
      "updated": Timestamp(date: Date())])
  }

  func performBatchUpdate(instructions: [(endpoint: FirestoreEndpoint, params: [FirestoreQueryParam])]) async throws {
    let batch = Firestore.firestore().batch()

    for instruction in instructions {
      guard let ref = instruction.endpoint.path as? DocumentReference else {
        throw FirestoreServiceError.documentNotFound
      }

      var dict: [String: Any] = [:]
      for param in instruction.params {
        dict[param.key] = param.value
      }
      dict["updated"] = Timestamp(date: Date())

      batch.updateData(dict, forDocument: ref)
    }

    try await batch.commit()
  }

  func deleteAllUserData(userId: String) async throws {
    let userCollections = ["spendings", "accounts", "projects", "income_sources", "budget"]
    let db = Firestore.firestore()
    let batch = db.batch()
    var hasDataToDelete = false

    // 1. Iterate over all collections to find user data
    try await withThrowingTaskGroup(of: [QueryDocumentSnapshot].self) { group in
      for collection in userCollections {
        group.addTask {
          let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
          return snapshot.documents
        }
      }

      // Collect all documents
      for try await documents in group {
        for doc in documents {
          batch.deleteDocument(doc.reference)
          hasDataToDelete = true
        }
      }
    }

    // 2. Commit Batch (Only if data exists)
    if hasDataToDelete {
      try await batch.commit()
    }
  }
}
