//
//  Untitled.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import UIKit
import CoreLocation

struct ProfileData: Identifiable {
    var id: UUID
    var username: String
    var age: Int16
    var gender: Gender
    var goal: Goal
    var image: UIImage
    var height: Double
    var targetWeight: Double
    var notifications: Bool
    
    static let sampleProfile1 = ProfileData (
        id: UUID(),
        username: "User",
        age: 18,
        gender: .Male,
        goal: .Maintain,
        image: UIImage(),
        height: 0,
        targetWeight: 0.0,
        notifications: true
    )
}

enum Gender: Int16, CaseIterable, Identifiable {
    var id: Self {self}
    case Male = 1
    case Female = 2
    
    var name: String {
        String(describing: self)
    }
    
}

enum Goal: Int16, CaseIterable, Identifiable {
    var id: Self {self}
    
    case Lose = 1
    case Gain = 2
    case Maintain = 3
    
    var name: String {
        String(describing: self)
    }
}

