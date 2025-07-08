//
//  HomePageState.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//

import Observation
import SwiftUI

@Observable
final class HomePageState {
    // MARK: - Profile
    var profile: ProfileData? = nil
    
    // MARK: - Plan targets
    var targetCalories: Double = 0
    var targetProteins: Double = 0
    var targetCarbs: Double = 0
    var targetFats: Double = 0
    var targetFiber: Double = 0

    // MARK: - Actual intake values
    var consumedCalories: Double = 0
    var consumedProteins: Double = 0
    var consumedCarbs: Double = 0
    var consumedFats: Double = 0
    var consumedFiber: Double = 0

    // MARK: - Weight info
    var currentWeight: Double = 0
    var weightChange: Double = 0
    
    var weightGoal: Goal = .Maintain

    // MARK: - Meals eaten today 
    var todaysMeals: [MealData] = []
    
    // MARK: - UI state
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed properties

    var caloriesProgress: Double {
        targetCalories > 0 ? min(consumedCalories / targetCalories, 1) : 0
    }

    var proteinsProgress: Double {
        targetProteins > 0 ? min(consumedProteins / targetProteins, 1) : 0
    }

    var carbsProgress: Double {
        targetCarbs > 0 ? min(consumedCarbs / targetCarbs, 1) : 0
    }

    var fatsProgress: Double {
        targetFats > 0 ? min(consumedFats / targetFats, 1) : 0
    }

    var fiberProgress: Double {
        targetFiber > 0 ? min(consumedFiber / targetFiber, 1) : 0
    }
}

