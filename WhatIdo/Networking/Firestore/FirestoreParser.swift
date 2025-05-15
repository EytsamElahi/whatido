//
//  FirestoreParser.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import FirebaseFirestore

struct FirestoreParser {
    static func parse<T: Decodable>(_ documentData: [String: Any], type: T.Type) throws -> T {
        do {
            debugPrint("documents", documentData)
            var modifiedData = documentData

            // Convert only date2 from Timestamp to a JSON-compatible format
            if let date2Timestamp = modifiedData["date"] as? FirebaseFirestore.Timestamp {
                let date2 = date2Timestamp.dateValue()
                print("📆 Original Date:", date2)
                print("🕒 Seconds:", date2.timeIntervalSince1970)
                modifiedData["date"] = date2.timeIntervalSince1970
//                print("***MODIFIED DATE",date2Timestamp.dateValue())
            }

            // Serialize the modified dictionary to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: modifiedData, options: [.fragmentsAllowed])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            throw FirestoreServiceError.parseError
        }
    }
}
