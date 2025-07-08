//
//  MealData.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//
import UIKit

struct MealData: Identifiable {
    var id: UUID
    var name: String
    var mealType: MealType
    var servingSize: Double
    var servingUnit: String
    var calories: Double
    var proteins: Double
    var carbs: Double
    var fiber: Double
    var fats: Double
    var isCustom: Bool
    
    static let sampleMeal1 = MealData (
        id: UUID(),
        name: "Monster Energy drink",
        mealType: .Lunch,
        servingSize: 100,
        servingUnit: "ml",
        calories: 46,
        proteins: 0.25,
        carbs: 1.1,
        fiber: 0,
        fats: 0.08,
        isCustom: false
    )
}

enum MealType: Int16, CaseIterable, Identifiable {
    var id: Self {self}
    
    case Breakfast = 1
    case Lunch = 2
    case Dinner = 3
    
    var name: String {
        switch self {
        case .Breakfast: return "Breakfast"
        case .Lunch: return "Lunch"
        case .Dinner: return "Dinner"
        }
    }
}
