//
//  SpendingType.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

struct SpendingType: Codable {
    let id: Int?
    let catId: Int?
    let name: String?
}

extension SpendingType {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case catId = "cat_id"
        case name = "name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        catId = try values.decodeIfPresent(Int.self, forKey: .catId)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}

struct SpendingCategory: Codable {
    let id: Int
    let name: String
}

extension SpendingCategory {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
    }
}
