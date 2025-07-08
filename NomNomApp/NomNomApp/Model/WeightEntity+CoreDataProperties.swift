//
//  WeightEntity+CoreDataProperties.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
//

import Foundation
import CoreData


extension WeightEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightEntity> {
        return NSFetchRequest<WeightEntity>(entityName: "WeightEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var value: Double

}

extension WeightEntity : Identifiable {

}
