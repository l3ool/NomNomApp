//
//  MealDetailView.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 18.06.2025.
//
import SwiftUI

struct MealDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MealDetailViewModel

    var body: some View {
        NavigationView {
            Form {
                // Čas a typ jídla
                Section(header: Text("Meal Time")) {
                    Picker("Meal Type", selection: $viewModel.mealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.name).tag(type)
                        }
                    }
                    DatePicker("Date", selection: $viewModel.mealDate, displayedComponents: [.date])
                }

                // Informace o jídle
                Section(header: Text("Meal")) {
                    Text(viewModel.mealName)
                    Stepper(value: $viewModel.amount, in: 1...10) {
                        Text("Amount: \(viewModel.amount)x \(viewModel.unitLabel)")
                    }
                }

                // Nutriční info
                Section(header: Text("Nutrition Total")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(Int(viewModel.totalCalories)) kcal")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Protein")
                        Spacer()
                        Text("\(viewModel.totalProtein, specifier: "%.1f") g")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Fat")
                        Spacer()
                        Text("\(viewModel.totalFat, specifier: "%.1f") g")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Carbs")
                        Spacer()
                        Text("\(viewModel.totalCarbs, specifier: "%.1f") g")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(viewModel.mealType.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Record") {
                        viewModel.recordMeal()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
