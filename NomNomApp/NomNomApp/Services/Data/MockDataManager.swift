//
//  MockDataManager.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import Foundation
import CoreData
import UIKit

final class MockDataManager: DataManaging {
    
    var context: NSManagedObjectContext {
        NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    private var prof: ProfileEntity?
    
    // MARK: - Profile Management
    
    func saveProfile(profile: ProfileEntity) {
        prof = profile
    }
    
    func fetchProfile() -> ProfileEntity? {
        return prof
    }
    
    func deleteProfile(profile: ProfileEntity) {
        guard let profileId = profile.id, let currentId = prof?.id else { return }
        if currentId == profileId {
            prof = nil
        }
    }
    
    // MARK: - Day Management
    private var days: [UUID: DayMyEntity] = [:]

    func saveDay(day: DayMyEntity) {
        guard let id = day.id else { return }
        days[id] = day
    }

    func fetchDayWithId(id: UUID) -> DayMyEntity? {
        return days[id]
    }

    func fetchAllDays() -> [DayMyEntity] {
        return Array(days.values)
    }

    // MARK: - Meal Management
    private var meals: [UUID: MealEntity] = [:]
    private var mealsByDay: [UUID: [MealEntity]] = [:]

    func addMeal(meal: MealEntity, day: DayMyEntity) {
        guard let mealId = meal.id, let dayId = day.id else { return }
        meals[mealId] = meal
        mealsByDay[dayId, default: []].append(meal)
    }

    func fetchMeals(day: DayMyEntity) -> [MealEntity] {
        guard let dayId = day.id else { return [] }
        return mealsByDay[dayId] ?? []
    }

    func fetchMealWithId(id: UUID) -> MealEntity? {
        return meals[id]
    }

    func deleteMeal(meal: MealEntity) {
        guard let mealId = meal.id else { return }
        meals[mealId] = nil
        mealsByDay = mealsByDay.mapValues { $0.filter { $0.id != mealId } }
    }

    // MARK: - Weight Management
    private var weightEntries: [WeightEntity] = []

    func addWeightEntry(weight: WeightEntity) {
        weightEntries.append(weight)
    }

    func fetchWeightEntries() -> [WeightEntity] {
        return weightEntries
    }

    // MARK: - Notification Management
    private var notifications: [UUID: NotificationEntity] = [:]

    func addNotification(notification: NotificationEntity) {
        guard let id = notification.id else { return }
        notifications[id] = notification
    }

    func fetchNotifications() -> [NotificationEntity] {
        return Array(notifications.values)
    }

    func fetchNotificationWithId(id: UUID) -> NotificationEntity? {
        return notifications[id]
    }

    func removeNotification(notification: NotificationEntity) {
        guard let id = notification.id else { return }
        notifications[id] = nil
    }

    // MARK: - Sample Data
    func addSampleData() {
        for i in 0..<30 {
            let day = DayMyEntity(context: context)
            day.id = UUID()
            day.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())

            for j in 0..<3 {
                let meal = MealEntity(context: context)
                meal.id = UUID()
                meal.name = "Meal \(j)"
                meal.calories = Double.random(in: 300...700)
                meal.carbs = Double.random(in: 20...100)
                meal.fats = Double.random(in: 5...30)
                meal.proteins = Double.random(in: 10...50)
                meal.fiber = Double.random(in: 5...15)
                meal.relationship4 = day
            }
        }

    }


    func clearAllData() {
        prof = nil
        days.removeAll()
        meals.removeAll()
        mealsByDay.removeAll()
        weightEntries.removeAll()
        notifications.removeAll()
    }
}
