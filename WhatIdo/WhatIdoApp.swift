//
//  WhatIdoApp.swift
//  WhatIdo
//
//  Created by eytsam elahi on 28/04/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        // Load Firebase plist based on environment
        #if DEBUG
        print("🔧 App Environment: \(AppConfiguration.shared.environment.rawValue)")
        #endif
        
        if let filePath = AppConfiguration.shared.firebasePlistPath,
           let options = FirebaseOptions(contentsOfFile: filePath) {
            #if DEBUG
            print("🔥 Firebase configured with plist: \(filePath)")
            #endif
            FirebaseApp.configure(options: options)
        } else {
            // Fallback to default configuration
            #if DEBUG
            print("⚠️ Firebase using default configuration (no custom plist found)")
            #endif
            FirebaseApp.configure()
        }
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings

        return true
    }
}

@main
struct WhatIdoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var navManager = NavigationManager()
    private let appContainer = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            SplashView(container: appContainer)
                .environmentObject(navManager)
                .environment(\.dependencyContainer, appContainer)
        }
    }
}
