//
//  CoreDataManager.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import CoreData
import UIKit

final class CoreDataManager: DataManaging {
    
    private let container = NSPersistentContainer(name: "MyDatabase")
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Chyba při načítání persistent store: \(error)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Chyba při ukládání: \(error)")
            }
        }
    }
    
    // MARK: - Profile Management
    
    func saveProfile(profile: ProfileEntity) {
        deleteAll(ProfileEntity.self)
        context.insert(profile)
        saveContext()
    }
    
    func fetchProfile() -> ProfileEntity? {
        let request: NSFetchRequest<ProfileEntity> = ProfileEntity.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    func deleteProfile(profile: ProfileEntity) {
        context.delete(profile)
        saveContext()
    }
    
    // MARK: - Day Management
    
    func saveDay(day: DayMyEntity) {
        context.insert(day)
        saveContext()
    }
    
    func fetchDayWithId(id: UUID) -> DayMyEntity? {
        let request: NSFetchRequest<DayMyEntity> = DayMyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    func fetchAllDays() -> [DayMyEntity] {
        let request: NSFetchRequest<DayMyEntity> = DayMyEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchDay(for date: Date) -> DayMyEntity? {
        let calendar = Calendar.current
        
        // Zjistíme začátek dne a konec dne
        guard let startOfDay = calendar.startOfDay(for: date) as NSDate? else { return nil }
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay as Date)?.addingTimeInterval(-1) as NSDate? else { return nil }
        
        let request: NSFetchRequest<DayMyEntity> = DayMyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfDay, endOfDay)
        
        return try? context.fetch(request).first
    }

    
    // MARK: - Meal Management
    
    func addMeal(meal: MealEntity, day: DayMyEntity) {
        let context = container.viewContext

        // ⛑️ Bezpečně načti den z aktuálního kontextu
        guard let dayInContext = try? context.existingObject(with: day.objectID) as? DayMyEntity else {
            print("❌ Failed to get DayMyEntity in context")
            return
        }

        meal.relationship4 = dayInContext
        dayInContext.addToRelationship3(meal)

        do {
            try context.save()
        } catch {
            print("❌ Failed to save meal: \(error.localizedDescription)")
        }
    }


    
    func fetchMeals(day: DayMyEntity) -> [MealEntity] {
        let request: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        request.predicate = NSPredicate(format: "relationship4 == %@", day)
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchMealWithId(id: UUID) -> MealEntity? {
        let request: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    func deleteMeal(meal: MealEntity) {
        context.delete(meal)
        saveContext()
    }
    
    // MARK: - Weight Management
    
    func addWeightEntry(weight: WeightEntity) {
        context.insert(weight)
        saveContext()
    }
    
    func fetchWeightEntries() -> [WeightEntity] {
        let request: NSFetchRequest<WeightEntity> = WeightEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Notification Management
    
    func addNotification(notification: NotificationEntity) {
        context.insert(notification)
        saveContext()
    }
    
    func fetchNotifications() -> [NotificationEntity] {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchNotificationWithId(id: UUID) -> NotificationEntity? {
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
    func removeNotification(notification: NotificationEntity) {
        context.delete(notification)
        saveContext()
    }
    
    // MARK: - Sample Data
    
    func addSampleData() {
        let context = container.viewContext

        let profile = ProfileEntity(context: context)
        profile.id = UUID()
        profile.username = ""
        profile.age = 0
        profile.gender = 0
        profile.goal = 2
        profile.height = 0

        let day = DayMyEntity(context: context)
        day.id = UUID()
        day.date = Date()

        /*
        let meal = MealEntity(context: context)
        meal.id = UUID()
        meal.name = "Snídaně"
        meal.calories = 400
        meal.carbs = 30
        meal.fats = 10
        meal.proteins = 20
        meal.fiber = 5
        meal.servingSize = 1
        meal.servingUnit = "porce"
        meal.mealType = 0
        meal.isCustom = true
        meal.relationship4 = day
*/
        let weight = WeightEntity(context: context)
        weight.id = UUID()
        weight.date = Date()
        weight.value = 0

        let notification = NotificationEntity(context: context)
        notification.id = UUID()
        notification.time = Date()
        notification.title = "Snídaně"
        notification.isActive = true
        notification.relationship2 = profile

        profile.addToRelationship(notification)
/*
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

            let weightCount = Int.random(in: 1...3)
            for _ in 0..<weightCount {
                let weightEntry = WeightEntity(context: context)
                weightEntry.id = UUID()
                if let baseDate = day.date {
                    let randomHour = Int.random(in: 0...23)
                    let randomMinute = Int.random(in: 0...59)
                    let randomSecond = Int.random(in: 0...59)

                    var components = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
                    components.hour = randomHour
                    components.minute = randomMinute
                    components.second = randomSecond

                    weightEntry.date = Calendar.current.date(from: components)
                } else {
                    weightEntry.date = Date()
                }

                weightEntry.value = Double.random(in: 70...75)
            }
        }
*/
        saveContext()
    }

    
    func clearAllData() {
        deleteAll(ProfileEntity.self)
        deleteAll(DayMyEntity.self)
        deleteAll(MealEntity.self)
        deleteAll(WeightEntity.self)
        deleteAll(NotificationEntity.self)
        saveContext()
    }
    
    // MARK: - Helper
    
    private func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
    }
}
