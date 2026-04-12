//
//  AppConfiguration.swift
//  WhatIdo
//
//  Created by eytsam elahi on 24/01/2026.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppConfiguration")

/// Centralized configuration manager for environment-based settings
final class AppConfiguration {
    
    // MARK: - Singleton
    static let shared = AppConfiguration()
    private init() {}
    
    // MARK: - Environment
    enum Environment: String {
        case dev
        case prod
        
        var displayName: String {
            switch self {
            case .dev: return "Development"
            case .prod: return "Production"
            }
        }
    }
    
    /// Current environment based on xcconfig value in Info.plist
    var environment: Environment {
        guard let envString = Bundle.main.infoDictionary?["ENVIRONMENT"] as? String,
              let env = Environment(rawValue: envString) else {
            // Default to prod if not set (safety fallback)
            return .prod
        }
        return env
    }
    
    /// Convenience check for development environment
    var isDevelopment: Bool {
        environment == .dev
    }
    
    /// Convenience check for production environment
    var isProduction: Bool {
        environment == .prod
    }
    
    // MARK: - App Info
    
    /// App display name from Info.plist
    var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
        ?? "WhatIdo"
    }
    
    /// Bundle identifier
    var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.eytsam.yaruapp"
    }
    
    // MARK: - Firebase Configuration
    
    /// Path to the Firebase plist for the current environment
    var firebasePlistPath: String? {
        // Read plist name from Info.plist (set via xcconfig)
        let plistName = Bundle.main.infoDictionary?["FIREBASE_PLIST_NAME"] as? String ?? "GoogleService-Info"
        
        let directory: String
        switch environment {
        case .dev:
            directory = "Firebase/Dev"
        case .prod:
            directory = "Firebase/Prod"
        }
        
        // Try with directory first (for folder references)
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist", inDirectory: directory) {
            #if DEBUG
            logger.debug("Firebase plist loaded from: \(path, privacy: .public)")
            #endif
            return path
        }

        // Fallback: try without directory (for flat bundle structure)
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            #if DEBUG
            logger.debug("Firebase plist loaded from root: \(path, privacy: .public)")
            #endif
            return path
        }

        // Fallback: try default GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            #if DEBUG
            logger.warning("Fallback to default GoogleService-Info.plist: \(path, privacy: .public)")
            #endif
            return path
        }

        #if DEBUG
        logger.error("No Firebase plist found! Environment: \(self.environment.rawValue, privacy: .public)")
        #endif
        return nil
    }
    
    // MARK: - API Configuration (Extend as needed)
    
    /// Base API URL for backend services
    var baseAPIURL: String {
        switch environment {
        case .dev:
            return "https://dev-api.example.com"
        case .prod:
            return "https://api.example.com"
        }
    }
    
    // MARK: - Feature Flags (Extend as needed)
    
    /// Enable debug logging
    var isDebugLoggingEnabled: Bool {
        isDevelopment
    }
    
    /// Enable analytics
    var isAnalyticsEnabled: Bool {
        isProduction
    }
}
