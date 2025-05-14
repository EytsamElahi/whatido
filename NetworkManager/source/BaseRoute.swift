//
//  BaseRoute.swift
//  NetworkManager
//
//  Created by eytsam elahi on 02/02/2025.
//

import Foundation

public enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol BaseRoute {
    var path: String { get}
    var httpMethod: HttpMethod { get}
    var authHeaders: [String: String] { get }
}
