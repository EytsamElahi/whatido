//
//  NotificationSyncManager.swift
//  WhatIdo
//
//  Created by Antigravity on 30/01/2026.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore
import OSLog
import UserNotifications
import FirebaseAuth

/// Manages synchronization of notification tokens and preferences between the device and Firestore.
class NotificationSyncManager {
  static let shared = NotificationSyncManager()
  private let userRepo: UserRepositoryType
  private var syncTask: Task<Void, Never>?
  private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "NotificationSyncManager")

  init(userRepo: UserRepositoryType = UserRepository()) {
    self.userRepo = userRepo
  }

  /// Synchronizes the current FCM token to Firestore if a user is logged in.
  func syncToken() {
    guard let userId = Auth.auth().currentUser?.uid,
          let token = AppData.fcmToken else {
      return
    }

    syncTask?.cancel()
    syncTask = Task {
      let result = await userRepo.updateFCMToken(userId: userId, token: token)
      switch result {
      case .success:
        self.logger.info("FCM Token synced successfully")
      case .error(let message):
        self.logger.error("Failed to sync FCM Token: \(message, privacy: .public)")
      case .data:
        break
      }
    }
  }

  /// Updates the notification preference in Firestore.
  func updateNotificationPreference(enabled: Bool) async {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let result = await userRepo.updateEnableNotification(userId: userId, enable: enabled)
    if case .success = result {
      AppData.user?.enableNotification = enabled
      self.logger.info("Notification preference updated to \(enabled, privacy: .public)")
    }
  }
  
  /// Clears the FCM token on logout.
  func clearTokenOnLogout() async {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let _ = await userRepo.updateFCMToken(userId: userId, token: nil)
  }
}
