//
//  FirestoreError.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation

enum FirestoreServiceError: Error {
    case invalidPath
    case invalidType
    case collectionNotFound
    case documentNotFound
    case unknownError
    case parseError
    case invalidRequest
    case operationNotSupported
    case invalidQuery
    case operationNotAllowed
    case noInternet
}
