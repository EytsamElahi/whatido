//
//  AppStorage.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/05/2025.
//

import Foundation
import Combine
import OSLog

private let storageLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppStorage")

@propertyWrapper
struct AppStorage<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    private let publisher = PassthroughSubject<Value, Never>()

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Check whether we're dealing with an optional and remove the object if the new value is nil.
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }
}

@propertyWrapper
struct AppStorageObject<T: Codable> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }

            // Convert data to the desire data type
            do {
                let value = try JSONDecoder().decode(T.self, from: data)
                return value ?? defaultValue
            } catch {
                storageLogger.error("Error in decoding: \(error.localizedDescription, privacy: .public)")
            }
            return defaultValue
        }
        set {
            // Convert newValue to data
            //  let data = try? JSONEncoder().encode(newValue)
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                storageLogger.error("Error in encoding: \(error.localizedDescription, privacy: .public)")
            }
            // Set value to UserDefaults

        }
    }
}

public protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}
extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}
