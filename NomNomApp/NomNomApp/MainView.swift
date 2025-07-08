//
//  RootView.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("hasSeenAppIntro")
    private var hasSeenAppIntro: Bool = false
    @AppStorage("hasCompletedProfile")
    private var hasCompletedProfile = false
    
    var body: some View {
        if !hasSeenAppIntro {
            AppIntroView()
        } else if !hasCompletedProfile {
            FirstProfileView(onComplete: {
                hasCompletedProfile = true
            }, viewModel: FirstProfileViewModel(profile: .sampleProfile1, userWeight: 0.0))
        } else {
            ContentView()
        }
    }
}

#Preview {
    MainView()
}
