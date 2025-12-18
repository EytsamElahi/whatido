//
//  ProjectSpending.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/12/2025.
//


import Foundation

class ProjectSpending: FirestoreIdentifiable, AppDataType {
    var id: String = ""
    var name: String
    var budget: Double?
    var icon: String
    let created: Date?
    var status: String

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.budget = try container.decodeIfPresent(Double.self, forKey: .budget)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.created = try container.decodeIfPresent(Date.self, forKey: .created)
        self.status = try container.decode(String.self, forKey: .status)
    }

    init(id: String,
        name: String,
        budget: Double?,
        icon: String,
        status: String,
         created: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.budget = budget
        self.icon = icon
        self.status = status
        self.created = created
    }

    public static func == (lhs: ProjectSpending, rhs: ProjectSpending) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func convertToDto() -> ProjectDto {
        return ProjectDto(id: self.id, name: self.name, icon: self.icon, budget: self.budget, createdAt: self.created, status: self.status)
   }
}

