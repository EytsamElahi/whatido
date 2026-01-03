//
//  DUser.swift
//  WhatIdo
//
//  Created by eytsam elahi on 01/01/2026.
//

class DUser: FirestoreIdentifiable {
    var id: String = ""
    let name: String?
    let email: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
    }

    init(
        name: String?,
        email: String?,
    ) {
        self.name = name
        self.email = email
    }

    public static func == (lhs: DUser, rhs: DUser) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
