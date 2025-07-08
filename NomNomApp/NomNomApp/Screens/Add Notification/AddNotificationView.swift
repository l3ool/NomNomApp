//
//  AddNotificationView.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI

struct AddNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: NotificationViewModel

    @State var title: String = ""
    @State var time: Date = Date()
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Add Notification") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Title", text: $title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5))
                            .padding(.trailing, 150)
                    
                        DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    }
                    .padding(.vertical, 8)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        saveNewNotification()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveNewNotification(){
        let newNotification = NotificationData(
            id: UUID(),
            title: title,
            time: time,
            isActive: viewModel.state.profile.notifications
        )
        viewModel.saveNotification(notification: newNotification)
        viewModel.fetchNotifications()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    viewModel.notificationShedule(for: newNotification)
                } else {
                    print("Error")
                }
            }
    }
    
}
#Preview {
    //AddNotificationView(viewModel: NotificationViewModel(profile: <#ProfileData#>))
}
