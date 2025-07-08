//
//  NotoficationView.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI

struct NotificationView: View {    
    @Binding var isNotificationPresented: Bool
    
    @State var notifications = true
    @State var viewModel: NotificationViewModel
    
    init(isNotificationPresented: Binding<Bool>, viewModel: NotificationViewModel){
        self._isNotificationPresented = isNotificationPresented
        self.viewModel = viewModel
    }
    var body: some View {
        Form{
            Section("Notifications"){
                Toggle(
                    "Notifications",
                    isOn: $notifications
                )
                .onChange(of: notifications){
                    if notifications {
                        for notification in viewModel.state.notifications {
                            viewModel.notificationShedule(for: notification)
                            viewModel.turnOnTurnOffNotifications(active: true)
                            print("All active are active")
                        }
                    } else {
                        viewModel.cancelAllNotification()
                        viewModel.turnOnTurnOffNotifications(active: false)
                        print("All are canceled")
                    }
                }
            }
            
            Section {
                ForEach($viewModel.state.notifications) { $notification in
                    HStack {
                        Text(notification.title)
                        
                        Spacer()
                        
                        Text(notification.time, style: .time)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        if(notifications){
                            Toggle("", isOn: $notification.isActive)
                                .labelsHidden()
                                .frame(width: 50)
                                .onChange(of: notification.isActive){
                                    if $0 {
                                        viewModel.updateNotification(notification: notification, active: true)
                                        viewModel.notificationShedule(for: notification)
                                    } else {
                                        viewModel.updateNotification(notification: notification, active: false
                                        )
                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.removeNotification(notification: notification)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(.red)
                                }
                        } else {
                            Image(systemName: "bell.slash").foregroundColor(.gray)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.removeNotification(notification: notification)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(.red)
                                }

                        }
                    }
                }
            }

            Section{
                NavigationLink(destination: AddNotificationView(viewModel: viewModel)){
                    Text("Add notification")
                }
            }
        }.onAppear{
            viewModel.fetchNotifications()
            notifications = viewModel.state.profile.notifications
            if (viewModel.state.notifications.isEmpty){
                viewModel.fetchMainNotifications()
            }
            if !notifications{
                viewModel.cancelAllNotification()
            }
        }
             
    }
}

#Preview {
    //NotificationView( isNotificationPresented: .constant(true), viewModel: NotificationViewModel())
}
