//
//  MealEntity+CoreDataProperties.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
//

import Foundation
import CoreData


extension MealEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealEntity> {
        return NSFetchRequest<MealEntity>(entityName: "MealEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var servingSize: Double
    @NSManaged public var servingUnit: String?
    @NSManaged public var calories: Double
    @NSManaged public var proteins: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fats: Double
    @NSManaged public var fiber: Double
    @NSManaged public var mealType: Int16
    @NSManaged public var isCustom: Bool
    @NSManaged public var relationship4: DayMyEntity?

}

extension MealEntity : Identifiable {

}
