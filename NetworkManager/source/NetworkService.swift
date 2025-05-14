//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by eytsam elahi on 02/02/2025.
//

import Foundation
import Combine

public protocol NetworkService {
    func request<T: Codable>(route: URLRequest, shouldPersistData: Bool) async throws -> T
}

public extension NetworkService {
    func request<T: Codable>(route: URLRequest, shouldPersistData: Bool = false) async throws -> T {
        if let url = route.url?.absoluteString {
            debugPrint(url + " -> " + (String(data: route.httpBody ?? Data(), encoding: .utf8) ?? "Failed to Convert"))
        }

        guard let url = route.url else {
            // throw error if the url is invalid
            throw NetworkError.urlError()
        }

        if !Reachability.isConnectedToNetwork() {
            throw NetworkError.wifiError()
        }

        let session = URLSession.shared
        let (data, response) = try await session.data(for: route)
        guard let httpResponse = response as? HTTPURLResponse  else {
            throw NetworkError.urlError()
        }
        debugPrint(httpResponse)
        let statusCode = httpResponse.statusCode
        switch statusCode {
        case 200...299:
            let decodedResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
            guard let responseData = decodedResponse.data else {throw NetworkError.serializationError()}
            return (responseData)
        case 401:
            throw NetworkError.unauthorized()
        case 403:
            throw NetworkError.forbiddenError()
        case 404:
            throw NetworkError.notFound()
        case 500...599:
            throw NetworkError.serverError(statusCode: statusCode)
        default:
            throw NetworkError.urlError()
        }
    }
}
