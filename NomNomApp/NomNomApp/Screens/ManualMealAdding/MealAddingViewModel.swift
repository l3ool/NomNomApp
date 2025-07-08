//
//  MealAddingViewModel.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 19.06.2025.
//

import Foundation

class MealAddingViewModel: ObservableObject {
    @Published var mealType: MealType = .Breakfast
    @Published var mealDate: Date = Date()
    @Published var mealName: String = ""
    @Published var unitLabel: String = ""
    @Published var amount: Int = 1

    @Published var caloriesText: String = ""
    @Published var proteinText: String = ""
    @Published var fatText: String = ""
    @Published var carbsText: String = ""

    private let dataManager: CoreDataManager

    init(dataManager: CoreDataManager) {
        self.dataManager = dataManager
    }

    private func double(from text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }

    var isFormValid: Bool {
        !mealName.isEmpty &&
        !unitLabel.isEmpty &&
        amount > 0 &&
        double(from: caloriesText) != nil &&
        double(from: proteinText) != nil &&
        double(from: fatText) != nil &&
        double(from: carbsText) != nil
    }

    func recordMeal() {
        guard
            let cal = double(from: caloriesText),
            let pro = double(from: proteinText),
            let fat = double(from: fatText),
            let carbs = double(from: carbsText),
            !mealName.isEmpty,
            !unitLabel.isEmpty,
            amount > 0
        else {
            print("❌ Invalid input data")
            return
        }

        let context = dataManager.context
        let day: DayMyEntity

        if let existing = fetchDayByDate(mealDate) {
            if let resolved = try? context.existingObject(with: existing.objectID) as? DayMyEntity {
                day = resolved
            } else {
                print("⚠️ Chyba při načtení dne z contextu")
                return
            }
        } else {
            day = DayMyEntity(context: context)
            day.id = UUID()
            day.date = mealDate
        }

        let newMeal = MealEntity(context: context)
        newMeal.id = UUID()
        newMeal.name = mealName
        newMeal.servingUnit = unitLabel
        newMeal.servingSize = Double(amount)
        newMeal.mealType = mealType.rawValue
        newMeal.calories = cal * Double(amount)
        newMeal.proteins = pro * Double(amount)
        newMeal.fats = fat * Double(amount)
        newMeal.carbs = carbs * Double(amount)
        newMeal.isCustom = true

        dataManager.addMeal(meal: newMeal, day: day)
        print("✅ Meal saved successfully")
    }

    private func fetchDayByDate(_ date: Date) -> DayMyEntity? {
        let allDays = dataManager.fetchAllDays()
        let calendar = Calendar.current
        return allDays.first { calendar.isDate($0.date ?? Date.distantPast, inSameDayAs: date) }
    }
}
