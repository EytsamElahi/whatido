//
//  Spending.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

class Spending: FirestoreIdentifiable {
    var id: String = ""
    let name: String
    let amount: Double
    let date: Date
    let spendingType: SpendingType?
    let created: Date?
    let updated: Date?
    let source: String?
    let projectInfo: ProjectInfo?
    let accountType: DAccountType

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.date = try container.decode(Date.self, forKey: .date)
        self.spendingType = try container.decodeIfPresent(SpendingType.self, forKey: .spendingType)
        self.created = try container.decodeIfPresent(Date.self, forKey: .created)
        self.updated = try container.decodeIfPresent(Date.self, forKey: .updated)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.projectInfo = try container.decodeIfPresent(ProjectInfo.self, forKey: .projectInfo)
        self.accountType = try container.decode(DAccountType.self, forKey: .accountType)
    }

    init(name: String, amount: Double, date: Date, spendingType: SpendingType?, created: Date, source: String?, projectType: ProjectInfo? = nil, accountType: DAccountType) {
        self.name = name
        self.amount = amount
        self.date = date
        self.spendingType = spendingType
        self.updated = nil
        self.created = created
        self.source = source
        self.projectInfo = projectType
        self.accountType = accountType
    }

    public static func == (lhs: Spending, rhs: Spending) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

     func convertToDto() -> SpendingDto {
         return SpendingDto(id: self.id, name: self.name, amount: self.amount, date: self.date, type: self.spendingType?.name ?? "", created: self.created ?? Date(), spendingTypeId: spendingType?.id ?? -1, spendingCategoryId: spendingType?.catId ?? -1, fundSource: FundSource(rawValue: self.source ?? "Cash"), project: SpendingProjectDto(id: projectInfo?.id, projectName: projectInfo?.name, projectIcon: projectInfo?.icon), account: SpendingAccountDto(id: accountType.accountId ?? "", name: accountType.name ?? ""))
    }

}

// 'D' indicates for domain model
class DSpendingType: FirestoreIdentifiable {
    var id: String = ""
    let name: String

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
    }

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    public static func == (lhs: DSpendingType, rhs: DSpendingType) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class DAccountType: Codable {
    let accountId: String?
    let name: String?

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
    }

    init(name: String? = nil, accountId: String? = nil) {
        self.name = name
        self.accountId = accountId
    }

}
