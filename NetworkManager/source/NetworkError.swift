//
//  NetworkError.swift
//  NetworkManager
//
//  Created by eytsam elahi on 02/02/2025.
//

import Foundation

public struct NetworkError: Codable,Error {
    let error : String
    let statusCode: Int?

    static func urlError() -> NetworkError {
        return NetworkError(error: "There's some error in Url")
    }

    static func serializationError() -> NetworkError {
        return NetworkError(error: "Response Serialization Error. Please contact provider")
    }

    static func serverError(statusCode: Int) -> NetworkError {
        return NetworkError(error: "We are working really hard to make user experience better. There's work under progress. Please try again later", statusCode: statusCode)
    }

    static func forbiddenError() -> NetworkError {
        return NetworkError(error: "Request failed due to insufficient permissions", statusCode: 403)
    }

    static func nullDataError(statusCode: Int) -> NetworkError {
        return NetworkError(error: "Response Data is null", statusCode: statusCode)
    }

    static func wifiError()-> NetworkError {
        return NetworkError(error: "Please Check your Internet connection")
    }

    static func notFound()-> NetworkError {
        return NetworkError(error: "Query Data does not exist", statusCode: 404)
    }

    static func unauthorized()-> NetworkError {
        return NetworkError(error: "Failed to authorized", statusCode: 401)
    }

    public init(error: String, statusCode: Int? = nil) {
        self.error = error
        self.statusCode = statusCode
    }

}
