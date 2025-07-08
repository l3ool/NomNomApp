//
//  StatisticsGraphViewModel.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import SwiftUI
import Charts
import Foundation
import Combine

enum NutrientType: String, CaseIterable, Identifiable {
    case calories = "Calories"
    case proteins = "Proteins"
    case fats = "Fats"
    case weight = "Weight"

    var id: String { rawValue }
}

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case fortnight = "Fortnight"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .week: return 7
        case .fortnight: return 14
        case .month: return 30
        case .year: return 365
        }
    }
}

struct BarData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

class StatisticsGraphViewModel: ObservableObject {
    @Published var selectedNutrient: NutrientType = .calories
    @Published var selectedRange: TimeRange = .week
    @Published var barData: [BarData] = []
    @Published var lineData: [BarData] = []
    @Published var goal: Double? = nil

    private let coreData = CoreDataManager()

    func loadData() {
        switch selectedNutrient {
        case .weight:
            loadWeightData()
        default:
            loadNutrientData()
        }
    }

    private func loadNutrientData() {
        let allDays = coreData.fetchAllDays()

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let daysBack = selectedRange.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: startOfToday)!

        let filteredDays = allDays.filter {
            if let date = $0.date {
                return date >= startDate && date < endOfToday
            }
            return false
        }

        let data = filteredDays.compactMap { day -> BarData? in
            guard let meals = day.relationship3 as? Set<MealEntity>, let date = day.date else { return nil }

            let total = meals.reduce(0.0) { sum, meal in
                switch selectedNutrient {
                case .calories: return sum + meal.calories
                case .proteins: return sum + meal.proteins
                case .fats: return sum + meal.fats
                default: return sum
                }
            }

            return BarData(date: date, value: total)
        }

        barData = data.sorted { $0.date < $1.date }

        goal = calculateGoalFromProfile()
    }

    private func loadWeightData() {
        let allWeights = coreData.fetchWeightEntries()

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let daysBack = selectedRange.days
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: startOfToday)!

        let filteredWeights = allWeights.filter {
            if let date = $0.date {
                return date >= startDate && date < endOfToday
            }
            return false
        }

        let data = filteredWeights.compactMap { weightEntry -> BarData? in
            guard let date = weightEntry.date, weightEntry.value != 0 else { return nil }
            return BarData(date: date, value: weightEntry.value)
        }


        lineData = data.sorted { $0.date < $1.date }
    }

    private func calculateGoalFromProfile() -> Double? {
        guard let profile = coreData.fetchProfile(),
              let gender = Gender(rawValue: profile.gender),
              let goal = Goal(rawValue: profile.goal) else {
            return nil
        }

        let age = Int(profile.age)
        let height = Double(profile.height)

        let weights = coreData.fetchWeightEntries()
        let latestWeight = weights
            .sorted(by: { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) })
            .first?.value ?? 0
        print("Latest weight: \(latestWeight)")


        let targets = NutritionCalculator.calculateNutritionTargets(
            weight: latestWeight,
            height: height,
            age: age,
            gender: gender,
            goal: goal
        )

        switch selectedNutrient {
        case .calories: return targets.calories
        case .proteins: return targets.protein
        case .fats: return targets.fats
        default: return nil
        }
    }


    func averageCaloriesLastYear() -> Double {
        let allDays = coreData.fetchAllDays()
        let calendar = Calendar.current
        var startOfToday = calendar.startOfDay(for: Date())
        startOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let oneYearAgo = calendar.date(byAdding: .day, value: -365, to: startOfToday)!

        let daysInLastYear = allDays.filter {
            if let date = $0.date {
                return date >= oneYearAgo && date <= startOfToday
            }
            return false
        }

        var totalCalories: Double = 0
        var dayCount: Int = 0

        for day in daysInLastYear {
            if let meals = day.relationship3 as? Set<MealEntity> {
                let dayCalories = meals.reduce(0.0) { $0 + $1.calories }
                if dayCalories > 0 {
                    totalCalories += dayCalories
                    dayCount += 1
                }
            }
        }

        guard dayCount > 0 else { return 0 }
        return totalCalories / Double(dayCount)
    }

}
