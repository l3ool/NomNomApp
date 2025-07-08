//
//  NomNomAppApp.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import SwiftUI

@main
struct NomNomAppApp: App {
    
    let notificationDelegate = NotificationManager()
    
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted? \(granted)")
            }
        }
    }
}
