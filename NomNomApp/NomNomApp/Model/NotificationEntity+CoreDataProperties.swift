//
//  NotificationEntity+CoreDataProperties.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
//

import Foundation
import CoreData


extension NotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationEntity> {
        return NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var time: Date?
    @NSManaged public var title: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var relationship2: ProfileEntity?

}

extension NotificationEntity : Identifiable {

}
