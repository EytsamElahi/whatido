//
//  WhatIdoApp.swift
//  WhatIdo
//
//  Created by eytsam elahi on 28/04/2025.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct WhatIdoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var navManager = NavigationManager()

    var body: some Scene {
        WindowGroup {
            SpendsListingView()
                .environmentObject(navManager)
        }
    }
}
