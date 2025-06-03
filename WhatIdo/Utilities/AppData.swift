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
}
