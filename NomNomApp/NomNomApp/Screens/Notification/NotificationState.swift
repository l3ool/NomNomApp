//
//  NotificationState.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import Observation

@Observable
final class NotificationState {
    var notifications: [NotificationData] = []
    var profile: ProfileData
    
    init(profile: ProfileData){
        self.profile = profile
    }
}
