//
//  FirstProfileViewModel.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import Observation

import SwiftUI

@Observable
class FirstProfileViewModel: ObservableObject {
    var state: FirstProfileState
    private var dataManager: DataManaging
    
    init(profile: ProfileData, userWeight: Double){
        dataManager = DIContainer.shared.resolve()
        state = FirstProfileState(profile: profile, userWeight: userWeight)
    }
}

extension FirstProfileViewModel {
    func saveProfile(
        username: String,
        age: String,
        gender: Gender,
        weight: Double,
        height: Double,
        goal: Goal,
        targetWeight: Double
    ){
        let profile = ProfileEntity(context: dataManager.context)
        profile.username = username
        profile.age = Int16(age) ?? 0
        profile.height = height
        profile.gender = gender.rawValue
        profile.targetWeight = targetWeight
        profile.goal = goal.rawValue
        profile.notifications = true
        
    
        let newWeight = WeightEntity(context: dataManager.context)
        
        newWeight.id = UUID()
        newWeight.value = weight
        newWeight.date = Date()
        
        
        print("Username to save: \(String(describing: profile.username))")
        
        dataManager.addWeightEntry(weight: newWeight)
        
        print("Weight: \(newWeight.value)")
        
        print()
        dataManager.saveProfile(profile: profile)
        
    }
}
