//
//  ProfileView.swift
//  NomNomApp
//
//  Created by Peter Machava on 18.06.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var isMyGoalPresented = false
    @State private var isNotificationPresented = false
    @State var viewModel: ProfileViewModel
    @Binding var isProfileVisible: Bool
    
    @State var name: String = ""
    @State var age: String = ""
    @State var weight: String = ""
    @State var gender: Gender = .Male
    @State var myGoal: Goal = .Maintain
    @State var height: String = ""
    @State var notification: String = ""
    
    
    var body: some View {
        NavigationStack{
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
                        .pickerStyle(.menu)
                    }
                    
                }
                
                Section{
                    NavigationLink(destination: MyGoalView(isMyGoalPresented: $isMyGoalPresented, viewModel: viewModel)) {
                            Text("My goal")
                    }
                }
                
                Section{
                    NavigationLink(destination: NotificationView(isNotificationPresented: $isNotificationPresented, viewModel: NotificationViewModel(profile: viewModel.state.profile))){
                        Text("Notification")
                    }
                }
            }
            .onAppear{
                name = viewModel.state.profile.username
                age = String(viewModel.state.profile.age)
                gender = viewModel.state.profile.gender
                myGoal = viewModel.state.profile.goal
                weight = String(viewModel.state.userWeight)
                height = String(viewModel.state.profile.height)
                
            }
            .toolbar{
                ToolbarItemGroup(placement: .topBarLeading){
                    Button("Cancel"){
                        isProfileVisible.toggle()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button("Save"){
                        viewModel.saveProfile(
                            username: name, age: age, gender: gender, weight: Double(weight) ?? 0.0, height: Double(height) ?? 0
                        )
                        isProfileVisible.toggle()
                    }
                }
            }
        }
    }

}

#Preview {
   
}

