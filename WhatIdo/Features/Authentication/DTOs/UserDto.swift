//
//  UserDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/01/2026.
//

import Swift

struct UserDto: Hashable, Codable {
    let id: String
    let name: String?
    let email: String?
    let currency: String?
    var enableNotification: Bool?
}
