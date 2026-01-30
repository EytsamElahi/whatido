//
//  AppData.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import Foundation

class AppData {
    @AppStorage(key: "budget", defaultValue: nil)
    static var budget: [String:Double]?

    @AppStorage(key: "fcmToken", defaultValue: nil)
    static var fcmToken: String?

    @AppStorage(key: "hasCompletedOnboarding", defaultValue: false)
    static var hasCompletedOnboarding: Bool

    @AppStorageObject(key: "preferredCurrency", defaultValue: nil)
    static var prefCurrency: CurrencyOption?

    @AppStorageObject(key: "user", defaultValue: nil)
    static var user: UserDto?

    static func clear() {
        budget = nil
        prefCurrency = nil
        user = nil
    }

}
