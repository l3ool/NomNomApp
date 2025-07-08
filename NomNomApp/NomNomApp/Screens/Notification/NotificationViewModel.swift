//
//  NotificationViewModel.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI
import UserNotifications

@Observable
class NotificationViewModel: ObservableObject {
    var state: NotificationState
    
    private var dataManager: DataManaging
    
    init(profile: ProfileData){
        dataManager = DIContainer.shared.resolve()
        state = NotificationState(profile: profile)
    }
}

extension NotificationViewModel {
    func fetchNotifications(){
        let notifications: [NotificationEntity] = dataManager.fetchNotifications()
        
        state.notifications = notifications.map{
            return NotificationData(
                id: $0.id ?? UUID(),
                title: $0.title ?? "No title",
                time: $0.time ?? Date(),
                isActive: $0.isActive 
            )
        }
       
    }
    
    func saveNotification(notification: NotificationData){
        
        guard !notification.title.isEmpty else {
            print("Cannot be empty")
            return
        }
            
        let notif = NotificationEntity(context: dataManager.context)
        notif.id = notification.id
        notif.isActive = notification.isActive
        notif.time = notification.time
        notif.title = notification.title

        dataManager.addNotification(notification: notif)
    }
    
    func updateNotification(notification: NotificationData, active: Bool){
        let notif = dataManager.fetchNotificationWithId(id: notification.id)
        notif?.isActive = active
        
        print("Changed: \(String(describing: notif?.isActive))")
        dataManager.addNotification(notification: notif!)
    }
    
    func fetchMainNotifications(){
        dataManager.addMainNotifications()
        fetchNotifications()
    }
    
    func notificationShedule(for notification: NotificationData) {
        
        guard notification.isActive else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                return
        }
        
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notification.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeNotification(notification: NotificationData){
        if notification.isActive {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
        }
        
        if let notif = dataManager.fetchNotificationWithId(id: notification.id) {
            dataManager.removeNotification(notification: notif)
            fetchNotifications()
        }
    }
    
    
    func cancelAllNotification(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func turnOnTurnOffNotifications(active: Bool){
        let profile = dataManager.fetchProfile()
        profile?.notifications = active
        state.profile.notifications = active
        dataManager.saveProfile(profile: profile!)
        print("Saved: \(String(describing: profile?.notifications))")
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter.string(from: date)
    }
}
