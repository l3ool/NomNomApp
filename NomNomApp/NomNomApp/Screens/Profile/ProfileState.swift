//
//  ProfileState.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import Observation
import MapKit
import SwiftUI

@Observable
final class ProfileState {
    var profile: ProfileData
    var userWeight: Double
    
    init(profile: ProfileData, userWeight: Double) {
        self.profile = profile
        self.userWeight = userWeight
    }
}
