//
//  DayMyEntity+CoreDataProperties.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
//

import Foundation
import CoreData


extension DayMyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayMyEntity> {
        return NSFetchRequest<DayMyEntity>(entityName: "DayMyEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var meals: NSSet?

}

extension DayMyEntity : Identifiable {
    var mealsArray: [MealEntity] {
        let set = meals as? Set<MealEntity> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
