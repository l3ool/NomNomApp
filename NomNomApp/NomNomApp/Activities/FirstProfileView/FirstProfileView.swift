//
//  ProfileView.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import SwiftUI

struct FirstProfileView: View {
    
    var onComplete: () -> Void
    
    var viewModel: FirstProfileViewModel
    
    init(onComplete: @escaping () -> Void, viewModel: FirstProfileViewModel) {
        self.onComplete = onComplete
        self.viewModel = viewModel
    }
    
    
    @State var name: String = "Username"
    @State var age: String = ""
    @State var weight: String = ""
    @State var gender: Gender = .Male
    @State var myGoal: Goal = .Maintain
    @State var height: String = ""
    @State var targetWeight: String = ""

    
    var body: some View {
        Form{
            Section{
                VStack(spacing: 8) {
                    HStack{
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .foregroundColor(.gray)
                            )
                        
                        TextField("", text: $name)
                            .font(.title2)
                            .bold()
                    }
                }
            }
            
            Section{
                
                ProfileRow(label: "Age", value: $age)
                
                ProfileRow(label: "Weight", unit: "kg", value: $weight)
                
                ProfileRow(label: "Height", unit: "cm", value: $height)
                
                
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases) {option in
                        Text(option.name).tag(option)
                    }
                    
                }
                .pickerStyle(.menu)
                .tint(.primaryGreen)
                
            }
            
            Section {
                    Picker("Goal", selection: $myGoal) {
                        ForEach(Goal.allCases) {
                            option in
                            Text(option.name)
                        }
                }
                    .pickerStyle(.menu)
                    .tint(.primaryGreen)
                
                ProfileRow(label: "Target weight", unit: "kg", value: $targetWeight)
            }
            Button("Continue to NomNomApp") {
                viewModel.saveProfile(
                    username: name,
                    age: age,
                    gender: gender,
                    weight: Double(weight) ?? 0.0,
                    height: Double(height) ?? 0.0,
                    goal: myGoal,
                    targetWeight: Double(targetWeight) ?? 0.0
                )
                onComplete()
            }
            .foregroundColor(.primaryGreen)
        }
    }
}

#Preview {
    FirstProfileView(onComplete: {}, viewModel: FirstProfileViewModel(profile: .sampleProfile1, userWeight: 0.0))
}
