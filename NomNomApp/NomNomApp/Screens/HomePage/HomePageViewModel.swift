//
//  HomePageViewModel.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//

import SwiftUI

@Observable
class HomePageViewModel: ObservableObject {
    var state: HomePageState = HomePageState()
    
    private var dataManager: CoreDataManager
    
    var selectedDay: Date = Date() {
            didSet {
                loadMealsForSelectedDay()
            }
        }
    
    init(){
        dataManager = DIContainer.shared.resolve()
        loadMealsForSelectedDay()
        
    }
    
}

extension HomePageViewModel {
    
    func loadProfile() {
        
        guard let profileEntity = dataManager.fetchProfile() else {
            state.errorMessage = "Profil nebyl nalezen"
            return
        }
        
        let weights = dataManager.fetchWeightEntries()
        let sortedWeights = weights.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }

        guard let latestWeight = sortedWeights.last?.value else {
            state.errorMessage = "Nebyla nalezena aktuální váha"
            return
        }
        
        var weightChange: Double = 0
            if sortedWeights.count >= 2 {
                let previousWeight = sortedWeights[sortedWeights.count - 2].value
                weightChange = latestWeight - previousWeight
            }
        
        let gender = Gender(rawValue: profileEntity.gender) ?? .Male
        let goal = Goal(rawValue: profileEntity.goal) ?? .Maintain
        let height = profileEntity.height
        let age = Int(profileEntity.age)

        let profileData = ProfileData(
            id: profileEntity.id ?? UUID(),
            username: profileEntity.username ?? "",
            age: profileEntity.age,
            gender: gender,
            goal: goal,
            image: UIImage(),
            height: profileEntity.height,
            targetWeight: profileEntity.targetWeight,
            notifications: profileEntity.notifications
        )

        print("Profile data: \(profileData.username)")
        print("Latest weight: \(latestWeight)")
        
        // Použij výpočet cílů
        let targets = NutritionCalculator.calculateNutritionTargets(
            weight: latestWeight,
            height: height,
            age: age,
            gender: gender,
            goal: goal
        )
        
        state.profile = profileData
        state.weightGoal = goal
        state.currentWeight = (round(latestWeight * 100)) / 100
        state.weightChange = (round(weightChange * 100)) / 100

        state.targetCalories = targets.calories
        state.targetProteins = targets.protein
        state.targetCarbs = targets.carbs
        state.targetFiber = targets.fiber
        state.targetFats = targets.fats
    }


        // MARK: - Load Weight Data
        
        func loadWeightData() {
            let weights = dataManager.fetchWeightEntries()
            guard !weights.isEmpty else {
                state.currentWeight = 0
                state.weightChange = 0
                return
            }
            
            // Seřadit podle data a převést na struct (pokud máš WeightData struct, použij ho, jinak pracuj jen s hodnotami)
            let sorted = weights.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
            
            if let lastWeight = sorted.last {
                state.currentWeight = lastWeight.value
            }
            
            if let firstWeight = sorted.first, let lastWeight = sorted.last {
                state.weightChange = lastWeight.value - firstWeight.value
            }
        }
        
        // MARK: - Load meals for a given day
        
    // Nová metoda na načtení jídla pro vybraný den
       func loadMealsForSelectedDay() {
           // Najdi entity dne podle data selectedDay
           guard let dayEntity = dataManager.fetchDay(for: selectedDay) else {
               state.todaysMeals = []
               return
           }
           loadMeals(for: dayEntity.id ?? UUID())
           loadProfile()
       }

       // Aktualizuj selectedDay a načti data
    func changeDay(by days: Int) {
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDay) ?? selectedDay
        
        // Ověříme, že existuje den pro nové datum
        if dataManager.fetchDay(for: newDate) != nil {
            selectedDay = newDate
            loadMealsForSelectedDay()
        } else {
            print("❌ Den pro datum \(newDate) neexistuje.")
        }
    }


       // existující metoda pro načtení jídel podle dayId (ponechána beze změny)
       func loadMeals(for dayId: UUID) {
           guard let dayEntity = dataManager.fetchDayWithId(id: dayId) else {
               state.errorMessage = "Den nenalezen"
               state.todaysMeals = []
               return
           }

           let mealEntities = dataManager.fetchMeals(day: dayEntity)

           let mealsData = mealEntities.compactMap { meal -> MealData? in
               guard let id = meal.id,
                     let name = meal.name,
                     let servingUnit = meal.servingUnit else { return nil }

               return MealData(
                   id: id,
                   name: name,
                   mealType: MealType(rawValue: meal.mealType) ?? .Lunch,
                   servingSize: meal.servingSize,
                   servingUnit: servingUnit,
                   calories: meal.calories,
                   proteins: meal.proteins,
                   carbs: meal.carbs,
                   fiber: meal.fiber,
                   fats: meal.fats,
                   isCustom: meal.isCustom
               )
           }

           state.todaysMeals = mealsData

           // Spočítej aktuální sumy
           state.consumedCalories = mealsData.reduce(0) { $0 + $1.calories }
           state.consumedProteins = mealsData.reduce(0) { $0 + $1.proteins }
           state.consumedCarbs = mealsData.reduce(0) { $0 + $1.carbs }
           state.consumedFats = mealsData.reduce(0) { $0 + $1.fats }
           state.consumedFiber = mealsData.reduce(0) { $0 + $1.fiber }
       }
    
    func removeMeal(_ meal: MealData) {
        if let item = dataManager.fetchMealWithId(id: meal.id){
            dataManager.deleteMeal(meal: item)
            loadMealsForSelectedDay()
            loadProfile()
        } else {
            print("Cannot fetch mealentity with given id")
        }
        
    }
}
