//
//  NotificationData.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import UIKit

struct NotificationData: Identifiable {
    var id: UUID
    var title: String
    var time: Date
    var isActive: Bool
}
