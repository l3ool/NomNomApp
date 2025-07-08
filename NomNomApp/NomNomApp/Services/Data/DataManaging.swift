//
//  DataManaging.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import CoreData
import UIKit

protocol DataManaging{
    
    var context: NSManagedObjectContext { get }
    
        // MARK: - Profile Management
    func saveProfile(profile: ProfileEntity)
    func fetchProfile() -> ProfileEntity?
    func deleteProfile(profile: ProfileEntity)

        // MARK: - Day Management
    func saveDay(day: DayMyEntity)
    func fetchDayWithId(id: UUID) -> DayMyEntity?
    func fetchAllDays() -> [DayMyEntity]

        // MARK: - Meal Management
    func addMeal(meal: MealEntity, day: DayMyEntity)
    func fetchMeals(day: DayMyEntity) -> [MealEntity]
    func fetchMealWithId(id: UUID) -> MealEntity?
    func deleteMeal(meal: MealEntity)

        // MARK: - Weight Management
    //mozna pri implementaci "toProfile" bude zbytecne
    func addWeightEntry(weight: WeightEntity)
    func fetchWeightEntries() -> [WeightEntity]

    // MARK: - Notification Management
    func addNotification(notification: NotificationEntity)
    func fetchNotifications() -> [NotificationEntity]
    func fetchNotificationWithId(id: UUID) -> NotificationEntity?
    func removeNotification(notification: NotificationEntity)


    // MARK: - Sample Data
    func addSampleData()
    func clearAllData()
    
    func addMainNotifications()
    
}

extension DataManaging {
    func addMainNotifications(){
        var breakfastTime = DateComponents()
        breakfastTime.hour = 8
        breakfastTime.minute = 0
        
        let breakfast = NotificationEntity(context: context)
        breakfast.id = UUID()
        breakfast.isActive = true
        breakfast.title = "Breakfast"
        breakfast.time = Calendar.current.date(from: breakfastTime)
        
        addNotification(notification: breakfast)
        
        var morningSnackTime = DateComponents()
        morningSnackTime.hour = 10
        morningSnackTime.minute = 0
        
        let morningSnack = NotificationEntity(context: context)
        morningSnack.id = UUID()
        morningSnack.isActive = false
        morningSnack.title = "Morning snack"
        morningSnack.time = Calendar.current.date(from: morningSnackTime)
        
        addNotification(notification: morningSnack)
        
        
        var launchTime = DateComponents()
        launchTime.hour = 12
        launchTime.minute = 30
        
        let launch = NotificationEntity(context: context)
        launch.id = UUID()
        launch.isActive = true
        launch.title = "Launch"
        launch.time = Calendar.current.date(from: launchTime)
        
        addNotification(notification: launch)
        
        var afternoonSnackTime = DateComponents()
        afternoonSnackTime.hour = 15
        afternoonSnackTime.minute = 0
        
        let afternoonSnack = NotificationEntity(context: context)
        afternoonSnack.id = UUID()
        afternoonSnack.isActive = false
        afternoonSnack.title = "Afternoon Snack"
        afternoonSnack.time = Calendar.current.date(from: afternoonSnackTime)
        
        addNotification(notification: afternoonSnack)
        
        
        
        var dinnerTime = DateComponents()
        dinnerTime.hour = 17
        dinnerTime.minute = 30
        
        let dinner = NotificationEntity(context: context)
        dinner.id = UUID()
        dinner.isActive = true
        dinner.title = "Dinner"
        dinner.time = Calendar.current.date(from: dinnerTime)
        
        addNotification(notification: dinner)
    }
}

