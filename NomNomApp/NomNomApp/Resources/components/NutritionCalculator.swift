//
//  NutritionCalculator.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 19.06.2025.
//

class NutritionCalculator {
    
    static func calculateNutritionTargets(
        weight: Double,
        height: Double,
        age: Int,
        gender: Gender,
        goal: Goal
    ) -> (calories: Double, protein: Double, carbs: Double, fats: Double, fiber: Double) {
        
        // BMR výpočet
        let bmr: Double
        switch gender {
        case .Male:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        case .Female:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        
        // Kalorie podle cíle
        let calorieMultiplier: Double
        switch goal {
        case .Maintain: calorieMultiplier = 1.5
        case .Lose: calorieMultiplier = 1.3
        case .Gain: calorieMultiplier = 1.7
        }
        
        let calories = bmr * calorieMultiplier
        
        // Makronutrienty
        let protein = weight * 1.8
        let proteinCalories = protein * 4

        let fiber = calories / 1000.0 * 14.0

        // Sacharidy: 50 % zbylých kalorií
        let remainingCaloriesAfterProtein = calories - proteinCalories
        let carbsCalories = remainingCaloriesAfterProtein * 0.5
        let fatsCalories = remainingCaloriesAfterProtein * 0.5

        let carbs = carbsCalories / 4.0
        let fats = fatsCalories / 9.0

        return (calories, protein, carbs, fats, fiber)
    }
}
