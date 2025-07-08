//
//  MyGoalView.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI

struct MyGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isMyGoalPresented: Bool
    
    @State var viewModel: ProfileViewModel
    
    @State var goal: Goal = .Maintain
    @State var targetWeight: String = ""
    
    var body: some View {
        NavigationStack{
            Form{
                Section("My goal"){
                    Picker("Goal", selection: $goal) {
                        ForEach(Goal.allCases) {
                            option in
                            Text(option.name)
                        }
                    }
                }
                Section("Custom"){
        
                    ProfileRow(label: "Target weight", unit: "kg", value: $targetWeight)
                }
            }
            .onAppear{
                goal = viewModel.state.profile.goal
                targetWeight = String(viewModel.state.profile.targetWeight)
            }
            .toolbar{
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button("Save"){
                        saveMyGoal()
                        print("Profile goal saving \(viewModel.state.profile.goal)")
                        dismiss()
                    }
                }
            }
        }
    }
    
    
    private func saveMyGoal(){
        viewModel.state.profile.goal = goal
        viewModel.state.profile.targetWeight = Double(targetWeight) ?? 0.0
    }
}

#Preview {
    //MyGoalView(isMyGoalPresented: .constant(true), viewModel: ProfileViewModel() )
}
