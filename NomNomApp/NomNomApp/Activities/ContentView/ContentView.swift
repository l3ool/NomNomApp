//
//  ContentView.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                "Home",
                systemImage: "house.fill",
                value: 0
            ){
                HomePageView(viewModel: HomePageViewModel())
            }
            
            Tab(
                "Stats",
                systemImage: "chart.bar.fill",
                value: 1
            ) {
                StatisticsGraphView()
            }
        }
        .tint(.primaryGreen)
    }
}

#Preview {
    ContentView()
}
