//
//  NotificationManager.swift
//  NomNomApp
//
//  Created by Peter Machava on 19.06.2025.
//

import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
