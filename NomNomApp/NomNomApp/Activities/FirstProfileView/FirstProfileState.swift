//
//  FirstProfileState.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//


import Observation
import SwiftUI

@Observable
final class FirstProfileState {
    var profile: ProfileData
    var userWeight: Double
    
    init(profile: ProfileData, userWeight: Double) {
        self.profile = profile
        self.userWeight = userWeight
    }
}

