//
//  UrlRequest.swift
//  NetworkManager
//
//  Created by eytsam elahi on 02/02/2025.
//

import Foundation

public typealias RouterInput<T> = (body: T?, query: [String: String]?)

public enum RequestType: Int {
    case json
    case formData
}

extension RequestType {
    var requestHeaders: [String : String] {
        var headers = [String: String]()
        switch self {
        case .json:
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
        case .formData:
            headers["Content-type"] = "multipart/form-data"
            headers["Accept"] = "application/json"
        }
        return headers
    }
}

public protocol Router {
    var baseUrl: String {get set}
    func CreateURLRequest<T: Codable>(route: BaseRoute,requestType: RequestType, _ input: RouterInput<T>) throws -> URLRequest
}

extension Router {
    func CreateURLRequest<T: Codable>(route: BaseRoute, requestType: RequestType, _ input: RouterInput<T>) throws -> URLRequest {
        guard let baseUrl = APIService.shared.getBaseUrl() else { throw NetworkError.init(error: "Base url not found")}
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseUrl
        components.path = route.path
        if let query = input.query {
            var queryItems = [URLQueryItem]()
            for (key, value) in query {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            components.queryItems = queryItems
        }

        var urlRequest: URLRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = route.httpMethod.rawValue

        let requestTypeHeaders = requestType.requestHeaders
        for (key, value) in requestTypeHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        for (key, value) in route.authHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        debugPrint("Auth headers \(route.authHeaders)")

        if let params = input.body {
            urlRequest.httpBody = Data()
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .millisecondsSince1970
                urlRequest.httpBody = try encoder.encode(params)
            } catch {
                debugPrint("Error")
            }
        }
        return urlRequest
    }
}
