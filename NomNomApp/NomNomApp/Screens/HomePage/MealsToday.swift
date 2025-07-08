//
//  MealsToday.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 19.06.2025.
//
import SwiftUI

struct MealsTodayView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @State private var expandedMealTypes: Set<MealType> = []

    private let mainMealTypes: [MealType] = [.Breakfast, .Lunch, .Dinner]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meals today")
                .font(.headline)

            ForEach(mainMealTypes, id: \.self) { mealType in
                let isExpanded = expandedMealTypes.contains(mealType)
                
                // mealsForType je [MealData]
                let mealsForType = viewModel.state.todaysMeals.filter { $0.mealType == mealType }

                MealsSection(
                    mealType: mealType,
                    isExpanded: isExpanded,
                    meals: mealsForType,
                    onToggleExpand: {
                        toggleMealType(mealType)
                    },
                    onDelete: { meal in
                        withAnimation {
                            viewModel.removeMeal(meal)
                        }
                    }
                )
            }
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func toggleMealType(_ mealType: MealType) {
        if expandedMealTypes.contains(mealType) {
            expandedMealTypes.remove(mealType)
        } else {
            expandedMealTypes.insert(mealType)
        }
    }
}

struct MealsSection: View {
    let mealType: MealType
    let isExpanded: Bool
    let meals: [MealData]
    let onToggleExpand: () -> Void
    let onDelete: (MealData) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: onToggleExpand) {
                HStack {
                    Text(mealType.name)
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                if meals.isEmpty {
                    Text("No meals")
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.leading, 12)
                } else {
                    List {
                        ForEach(meals) { meal in
                            MealRow(title: meal.name, kcal: Int(meal.calories))
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        onDelete(meal)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .tint(.red)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(meals.count) * 44) // fix výška
                }
            }
        }
        .padding(.bottom, 8)
    }
}
