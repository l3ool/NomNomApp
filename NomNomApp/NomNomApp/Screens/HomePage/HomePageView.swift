//
//  HomePageView.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//
import SwiftUI

struct HomePageView: View {
    @State private var viewModel: HomePageViewModel
    @State private var isSearchPresented: Bool = false
    @State private var isProfilePresented: Bool = false
    @State private var coreDataManager = CoreDataManager()
    
    private var weightChangeText: String {
        switch viewModel.state.weightGoal {
        case .Gain:
            return viewModel.state.weightChange > 0
                ? "+\(String(format: "%.1f", viewModel.state.weightChange))"
                : String(format: "%.1f", viewModel.state.weightChange)
        case .Lose:
            return viewModel.state.weightChange >= 0
                ? "+\(String(format: "%.1f", viewModel.state.weightChange))"
                : String(format: "%.1f", viewModel.state.weightChange)
        case .Maintain:
            return viewModel.state.weightChange >= 0
                ? "+\(String(format: "%.1f", viewModel.state.weightChange))"
                : String(format: "%.1f", viewModel.state.weightChange)
        default:
            return String(format: "%.1f", viewModel.state.weightChange)
        }
    }


    private var weightChangeColor: Color {
        switch viewModel.state.weightGoal {
        case .Gain:
            return viewModel.state.weightChange > 0 ? .green : .red
        case .Lose:
            return viewModel.state.weightChange < 0 ? .green : .red
        case .Maintain:
            return .gray
        default:
            return .gray
        }
    }



    
    init(viewModel: HomePageViewModel) {
        self.viewModel = viewModel
    }

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        // Top bar
                        ZStack {
                            HStack {
                                Text("NomNomApp")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    isProfilePresented.toggle()
                                }) {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)  // velikost ikony
                                }
                                .labelStyle(.iconOnly)
                                .tint(.black)

                            }
                            
                            Text("\(Int(round(viewModel.state.caloriesProgress * 100)))%")
                                .font(.caption)
                            
                        }
                        .padding(.horizontal)
                        
                        // Progress Circle + datum + šipky
                        VStack(spacing: 12) {
                            CircularProgressView(
                                progress: viewModel.state.caloriesProgress,
                                valueText: String(format: "%.1f", viewModel.state.consumedCalories),
                                totalText: String(format: "%.1f", viewModel.state.targetCalories)
                            )

                            
                            HStack {
                                Button(action: {
                                    viewModel.changeDay(by: -1) // ⬅️ posunout den zpět
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.headline)
                                        .tint(.gray)
                                }

                                Spacer()

                                VStack(spacing: 2) {
                                    Text(viewModel.selectedDay, formatter: dayNameFormatter)
                                        .font(.caption)
                                    Text(viewModel.selectedDay, formatter: dateFormatter)
                                        .font(.caption2)
                                }

                                Spacer()

                                Button(action: {
                                    viewModel.changeDay(by: 1) // ➡️ posunout den vpřed
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .tint(.gray)
                                }
                            }
                            .padding(.horizontal, 60)

                        }
                        
                        
                        // Váha
                        HStack(alignment: .center) {
                            Image(systemName: "scalemass")
                                .resizable()                      // aby šlo zvětšit
                                .scaledToFit()                    // zachovat poměr stran
                                .frame(width: 35, height: 35)    // zvětšená velikost ikony
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.primaryGreen))
                            
                            VStack {
                                Text("\(viewModel.state.currentWeight, specifier: "%.1f") kg")
                                    .font(.title2)
                                    .bold()
                                
                                Text(weightChangeText)
                                    .font(.caption)
                                    .foregroundColor(weightChangeColor)
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardColor)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Hledací řádek
                    Button(action: {
                        isSearchPresented = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            Text("Search or scan food")
                                .foregroundColor(.gray)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.cardColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    
                    
                    // Nutrient grid
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                        NutrientCard(
                            title: "Protein",
                            value: viewModel.state.consumedProteins,
                            total: viewModel.state.targetProteins,
                            color: .orange,
                            systemIconName: "bolt.fill")
                        
                        NutrientCard(
                            title: "Carbs",
                            value: viewModel.state.consumedCarbs,
                            total: viewModel.state.targetCarbs,
                            color: .blue,
                            systemIconName: "flame.fill"
                        )
                        NutrientCard(
                            title: "Fats",
                            value: viewModel.state.consumedFats,
                            total: viewModel.state.targetFats,
                            color: .purple,
                            systemIconName: "drop.fill"
                        )
                        PlaceholderCard()
                    }
                    
                    .padding(.horizontal)
                    
                    // Meals today - dynamicky podle MealType
                    MealsTodayView(viewModel: viewModel)
                }
                .padding(.top)
            }
            .background(Color.backgroundColor)
            .navigationBarHidden(true)
        }
        .onAppear() {
            viewModel.loadProfile()
            viewModel.loadMealsForSelectedDay()
            
            let coreDataManager = CoreDataManager()
            if viewModel.state.profile == nil{
                coreDataManager.addSampleData()
            }
            print("Success")
        }
        
        .sheet(isPresented: $isSearchPresented) {
            FoodSearchView(dataManager: coreDataManager, homeViewModel: viewModel)
        }
        
        .sheet(isPresented: $isProfilePresented,
               onDismiss: {
            viewModel.loadProfile()
        } ){
            ProfileView(viewModel: ProfileViewModel(profile: viewModel.state.profile ?? ProfileData.sampleProfile1, userWeight: viewModel.state.currentWeight), isProfileVisible: $isProfilePresented)
        }
    }
    
    // Pomocné formátovací funkce
    let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // celý název dne v týdnu, např. "Saturday"
        return formatter
    }()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

}
