//
//  FoodSearchResult.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 18.06.2025.
//
import SwiftUI
/*
struct FoodSearchResult: Identifiable, Decodable {
    let id = UUID()
    let foodID: String
    let name: String
    let description: String
    
    // Parsované nutriční hodnoty
    var calories: Double?
    var protein: Double?
    var fat: Double?
    var carbs: Double?

    enum CodingKeys: String, CodingKey {
        case foodID = "food_id"
        case name = "food_name"
        case description = "food_description"
    }

    var shortDescription: String {
        // Vezme část před pomlčkou
        description.components(separatedBy: " - ").first ?? description
    }

    mutating func parseNutrition() {
        let components = description.components(separatedBy: "|")
        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("Calories:") {
                calories = Double(trimmed.replacingOccurrences(of: "Calories:", with: "").replacingOccurrences(of: "kcal", with: "").trimmingCharacters(in: .whitespaces))
            } else if trimmed.contains("Protein:") {
                protein = Double(trimmed.replacingOccurrences(of: "Protein:", with: "").replacingOccurrences(of: "g", with: "").trimmingCharacters(in: .whitespaces))
            } else if trimmed.contains("Fat:") {
                fat = Double(trimmed.replacingOccurrences(of: "Fat:", with: "").replacingOccurrences(of: "g", with: "").trimmingCharacters(in: .whitespaces))
            } else if trimmed.contains("Carbs:") {
                carbs = Double(trimmed.replacingOccurrences(of: "Carbs:", with: "").replacingOccurrences(of: "g", with: "").trimmingCharacters(in: .whitespaces))
            }
        }
    }
}*/

struct FoodSearchResult: Identifiable {
    let id = UUID()
    let foodID: String
    let name: String
    let description: String
    let unitLabel: String

    var shortDescription: String {
        description.components(separatedBy: " - ").first ?? description
    }

    var calories: Double? {
        extractNutritionValue(from: description, prefix: "Calories:")
    }

    var protein: Double? {
        extractNutritionValue(from: description, prefix: "Protein:")
    }

    var fat: Double? {
        extractNutritionValue(from: description, prefix: "Fat:")
    }

    var carbs: Double? {
        extractNutritionValue(from: description, prefix: "Carbs:")
    }

    var caloriesDetail: Double?
    var proteinDetail: Double?
    var fatDetail: Double?
    var carbsDetail: Double?

    private func extractNutritionValue(from text: String, prefix: String) -> Double? {
        guard let range = text.range(of: prefix) else { return nil }
        let substring = text[range.upperBound...]
        let components = substring
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
        if let valueString = components.first?.replacingOccurrences(of: "kcal", with: "").replacingOccurrences(of: "g", with: ""),
           let value = Double(valueString) {
            return value
        }
        return nil
    }

    init(foodID: String, name: String, description: String = "", unitLabel: String = "",
         caloriesDetail: Double? = nil, proteinDetail: Double? = nil, fatDetail: Double? = nil, carbsDetail: Double? = nil) {
        self.foodID = foodID
        self.name = name
        self.description = description
        self.unitLabel = unitLabel
        self.caloriesDetail = caloriesDetail
        self.proteinDetail = proteinDetail
        self.fatDetail = fatDetail
        self.carbsDetail = carbsDetail
    }
}


