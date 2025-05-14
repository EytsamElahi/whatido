//
//  FirestoreIdentifiable.swift
//  WhatIdo
//
//  Created by eytsam elahi on 13/05/2025.
//

import Foundation
import FirebaseFirestore

protocol FirestoreIdentifiable: Hashable, Codable, Identifiable {
    var id: String { get set }
}

extension Encodable {
    func asDictionary() -> [String: Any] {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let formatter = ISO8601DateFormatter()
            let data = try encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                return dictionary.mapValues { value in
                    if let string = value as? String, let date = formatter.date(from: string) {
                       return Timestamp(date: date)
                    }
                    return value
                }
            }
        } catch {
            print("Failed to encode object to dictionary: \(error)")
        }
        return [:]
    }
}
