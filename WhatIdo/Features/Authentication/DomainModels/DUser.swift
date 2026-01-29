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
    var currency: String?
    var fcmToken: String?
    var enableNotification: Bool?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken)
        self.enableNotification = try container.decodeIfPresent(Bool.self, forKey: .enableNotification)
    }

    init(
        name: String?,
        email: String?,
        currency: String? = nil,
        fcmToken: String?,
        enableNotification: Bool? = nil
    ) {
        self.name = name
        self.email = email
        self.currency = currency
        self.fcmToken = fcmToken
        self.enableNotification = enableNotification
    }

    public static func == (lhs: DUser, rhs: DUser) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func toUserDto() -> UserDto {
        return UserDto(
            id: id,
            name: name,
            email: email,
            currency: currency,
            enableNotification: enableNotification
        )
    }
}
