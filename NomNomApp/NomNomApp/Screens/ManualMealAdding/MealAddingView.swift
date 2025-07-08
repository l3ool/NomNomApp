//
//  MealAddingView.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 19.06.2025.
//

import SwiftUI

struct MealAddingView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MealAddingViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Info")) {
                    TextField("Meal Name", text: $viewModel.mealName)
                    Picker("Meal Type", selection: $viewModel.mealType) {
                        ForEach(MealType.allCases) { type in
                            Text(type.name).tag(type)
                        }
                    }
                    DatePicker("Date", selection: $viewModel.mealDate, displayedComponents: [.date])
                    TextField("Unit Label (e.g. slice, apple)", text: $viewModel.unitLabel)
                    Stepper(value: $viewModel.amount, in: 1...20) {
                        Text("Amount: \(viewModel.amount)x \(viewModel.unitLabel)")
                    }
                }
                
                Section(header: Text("Nutrition per Unit")) {
                    TextField("Calories", text: $viewModel.caloriesText)
                        .keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $viewModel.proteinText)
                        .keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $viewModel.fatText)
                        .keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $viewModel.carbsText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.recordMeal()
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid) // ✅ disables button if form is incomplete
                    .bold()
                }
            }
        }
    }
}
