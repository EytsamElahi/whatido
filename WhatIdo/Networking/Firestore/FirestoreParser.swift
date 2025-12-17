//
//  FirestoreParser.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import FirebaseFirestore

//struct FirestoreParser {
//    static func parse<T: Decodable>(_ documentData: [String: Any], type: T.Type) throws -> T {
//        do {
//            debugPrint("documents", documentData)
//            var modifiedData = documentData
//
//            // Convert only date2 from Timestamp to a JSON-compatible format
//            if let date2Timestamp = modifiedData["date"] as? FirebaseFirestore.Timestamp {
//                let date2 = date2Timestamp.dateValue()
//                modifiedData["date"] = date2.timeIntervalSince1970
//            }
//            if let createdTS = modifiedData["created"] as? FirebaseFirestore.Timestamp {
//                let date2 = createdTS.dateValue()
//                modifiedData["created"] = date2.timeIntervalSince1970
//            }
//            if let updatedTS = modifiedData["updated"] as? FirebaseFirestore.Timestamp {
//                let date2 = updatedTS.dateValue()
//                modifiedData["updated"] = date2.timeIntervalSince1970
//            }
//
//            // Serialize the modified dictionary to JSON
//            let jsonData = try JSONSerialization.data(withJSONObject: modifiedData, options: [.fragmentsAllowed])
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .secondsSince1970
//            return try decoder.decode(T.self, from: jsonData)
//        } catch {
//            throw FirestoreServiceError.parseError
//        }
//    }
//}

struct FirestoreParser {
    private static func normalize(_ value: Any) -> Any {
        if let ts = value as? Timestamp {
            return ts.dateValue().timeIntervalSince1970
        }
        if let dict = value as? [String: Any] {
            return dict.mapValues { normalize($0) }
        }
        if let arr = value as? [Any] {
            return arr.map { normalize($0) }
        }
        return value
    }

    static func parse<T: Decodable>(_ documentData: [String: Any], type: T.Type) throws -> T {
        do {
            let normalized = documentData.mapValues { normalize($0) }
            let jsonData = try JSONSerialization.data(withJSONObject: normalized, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            throw FirestoreServiceError.parseError
        }
    }
}
