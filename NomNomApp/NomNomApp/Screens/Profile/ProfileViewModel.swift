//
//  ProfileViewModel.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI

@Observable
class ProfileViewModel: ObservableObject {
    var state: ProfileState
    private var dataManager: DataManaging
    
    init(profile: ProfileData, userWeight: Double){
        dataManager = DIContainer.shared.resolve()
        state = ProfileState(profile: profile, userWeight: userWeight)
    }
}

extension ProfileViewModel {
    
    func getProfile(){
        let profile = ProfileEntity(context: dataManager.context)
    
        let image: UIImage
        if let storedImageData = profile.image {
            image = UIImage(data: storedImageData) ?? UIImage()
        } else {
            image = UIImage()
        }
        state.profile = ProfileData(id: profile.id ?? UUID(),
                                    username: profile.username ?? "Unknown",
                                    age: profile.age,
                                    gender: Gender(rawValue: profile.gender) ?? .Male,
                                    goal: Goal(rawValue: profile.goal) ?? .Maintain,
                                    image: image,
                                    height: profile.height,
                                    targetWeight: profile.targetWeight,
                                    notifications: profile.notifications
        )
        
        
    }
    
    func saveProfile(
        username: String,
        age: String,
        gender: Gender,
        weight: Double,
        height: Double
    ){
        let profile = dataManager.fetchProfile()
        profile?.username = username
        profile?.age = Int16(age) ?? 0
        profile?.height = height
        profile?.gender = gender.rawValue
        profile?.goal = state.profile.goal.rawValue
        profile?.targetWeight = state.profile.targetWeight
        
    
        let newWeight = WeightEntity(context: dataManager.context)
        
        newWeight.id = UUID()
        newWeight.value = weight
        newWeight.date = Date()
        
        
        print("Username to save: \(String(describing: profile?.username))")
        
        dataManager.addWeightEntry(weight: newWeight)
        
        print("Weight: \(newWeight.value)")
        dataManager.saveProfile(profile: profile!)
        
    }
}
