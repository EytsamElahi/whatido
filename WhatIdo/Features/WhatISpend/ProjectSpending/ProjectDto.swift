//
//  ProjectDto.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//

import Foundation

// 1. Naya Model
struct ProjectDto: Identifiable, Hashable, Codable, AppDataType {
    let id: String
    let name: String        // e.g., "House Construction"
    let icon: String        // e.g., "house.fill"
    let budget: Double?     // Optional: Project ka total budget
    var createdAt: Date?
    let status: String      // "Active", "Completed"
}
