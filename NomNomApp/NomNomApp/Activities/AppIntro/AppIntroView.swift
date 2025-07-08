//
//  AppIntroView.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import SwiftUI

struct AppIntroView: View {
    
    
    @AppStorage("hasSeenAppIntro")
    var hasSeenAppIntro: Bool = false
    
    @State private var currentPage = 0
    
    init() {
           UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemGreen
           UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
       }
    
    var body: some View {
        TabView(selection: $currentPage){
            PageView(imageName: "AppIntro1", title: "Welcome", description: "Your personal nutrition assistant in your pocket.  Log meals, scan barcodes, and reach your health goals — one bite at a time.")
                .tag(0)
                PageView(imageName: "AppIntro2", title: "Track", description: "Track more than just calories — track your journey.  With NomNomApp, you get smart insights into your eating habits, daily goals, and weight progress.  Visualize your improvement and stay on top of your goals, every step of the way.").tag(1)
            PageView(imageName: "AppIntro3", title: "Achieve", description: "Let’s personalize your experience!  Next, we’ll take you to your profile to fill in your info — age, weight, goals, and more.")
                .tag(2)
            
            VStack {
                Spacer()
                Button("Let's Get Started") {
                    hasSeenAppIntro = true
                }
                .padding()
                .tint(.primaryGreen)
                .font(.title2)
                Spacer()
            }
            .tag(3)
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }

#Preview {
    AppIntroView()
}
