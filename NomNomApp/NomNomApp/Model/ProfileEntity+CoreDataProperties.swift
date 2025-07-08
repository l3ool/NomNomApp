//
//  ProfileEntity+CoreDataProperties.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
//

import Foundation
import CoreData


extension ProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        return NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var age: Int16
    @NSManaged public var gender: Int16
    @NSManaged public var goal: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var username: String?
    @NSManaged public var height: Double
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension ProfileEntity {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: NotificationEntity)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: NotificationEntity)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

extension ProfileEntity : Identifiable {
    
}
