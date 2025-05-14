//
//  BaseResponse.swift
//  NetworkManager
//
//  Created by eytsam elahi on 02/02/2025.
//

import Foundation

public struct BaseResponse<T: Codable>: Codable {
    let message: String?
    let status : Int?
    let data: T?

    public enum CodingKeys: String, CodingKey {
        case data = "data"
        case message = "message"
        case status = "status"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(T.self, forKey: .data)
    }

}
