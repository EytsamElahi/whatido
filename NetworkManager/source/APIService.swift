//
//  APIService.swift
//  NetworkManager
//
//  Created by eytsam elahi on 22/02/2025.
//

import Foundation
public class APIService {
    public static let shared = APIService()
    private var baseUrl: String?

    private init() {}

    public func setBaseUrl(_ url: String) {
        self.baseUrl = url
        debugPrint("Base url \(url)")
    }

    public func getBaseUrl() -> String? {
        return baseUrl
    }

}
