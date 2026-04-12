//
//  WhatIdoApp.swift
//  WhatIdo
//
//  Created by eytsam elahi on 28/04/2025.
//

import OSLog
import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

private let appLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppDelegate")

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        // Load Firebase plist based on environment
#if DEBUG
        appLogger.debug("App Environment: \(AppConfiguration.shared.environment.rawValue, privacy: .public)")
#endif

        if let filePath = AppConfiguration.shared.firebasePlistPath,
           let options = FirebaseOptions(contentsOfFile: filePath) {
#if DEBUG
            appLogger.debug("Firebase configured with plist: \(filePath, privacy: .public)")
#endif
            FirebaseApp.configure(options: options)
        } else {
            // Fallback to default configuration
#if DEBUG
            appLogger.warning("Firebase using default configuration (no custom plist found)")
#endif
            FirebaseApp.configure()
        }
        // Configure Firestore settings immediately after Firebase is configured,
        // before any other Firestore calls are made.
        let firestoreSettings = FirestoreSettings()
        firestoreSettings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        let db = Firestore.firestore()
        db.settings = firestoreSettings
        if let indexManager = db.persistentCacheIndexManager {
            indexManager.enableIndexAutoCreation()
        }
        // 1. Set the Messaging Delegate (CRITICAL)
        FirebaseMessaging.Messaging.messaging().delegate = self
        
        // 2. Register for Remote Notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        application.registerForRemoteNotifications()
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        appLogger.debug("Device Token: \(token, privacy: .private)")
        FirebaseMessaging.Messaging.messaging().apnsToken = deviceToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        let userInfo = content.userInfo
    }
}

extension AppDelegate: FirebaseMessaging.MessagingDelegate {
    func messaging(_ messaging: FirebaseMessaging.Messaging, didReceiveRegistrationToken fcmToken: String?) {
        appLogger.debug("Firebase registration token: \(fcmToken ?? "nil", privacy: .private)")
        AppData.fcmToken = fcmToken
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
