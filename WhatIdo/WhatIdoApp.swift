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
import FirebaseMessaging
import UserNotifications

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
        debugPrint("Device Token: \(token)")
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
        debugPrint("Firebase registration token: \(String(describing: fcmToken))")
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
