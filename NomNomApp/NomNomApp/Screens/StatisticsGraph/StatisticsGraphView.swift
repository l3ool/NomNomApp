//
//  StatisticsGraphView.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import SwiftUI
import Charts

struct StatisticsGraphView: View {
    @StateObject private var viewModel = StatisticsGraphViewModel()
    @StateObject private var statViewModel = StatisticsViewModel()


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                VStack(spacing: 16) {
                    Picker("Nutrient", selection: $viewModel.selectedNutrient) {
                        ForEach(NutrientType.allCases) { nutrient in
                            Text(nutrient.rawValue).tag(nutrient)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    Picker("Range", selection: $viewModel.selectedRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.cardColor)
                .cornerRadius(16)
                .padding(.horizontal)

                if viewModel.selectedNutrient == .weight {
                    Chart(viewModel.lineData) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.6),
                                    Color.blue,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.value)
                        )
                        .foregroundStyle(Color.blue
                        )
                        .symbolSize(50)
                    }
                    .frame(height: 300)
                    .padding()
                    .background(Color.cardColor)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .chartYScale(domain: {
                        let values = viewModel.lineData.map { $0.value }
                        if let min = values.min(), let max = values.max(), min != max {
                            let padding = (max - min) * 0.1
                            return (min - padding)...(max + padding)
                        } else if let onlyValue = values.first {
                            return (onlyValue - 1)...(onlyValue + 1)
                        } else {
                            return 0...10
                        }
                    }())
                } else {
                    Chart(viewModel.barData) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(Color.blue)

                        if let goal = viewModel.goal {
                            RuleMark(
                                y: .value("Goal", goal)
                            )
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(Color.primaryGreen)
                        }
                        
                        if !viewModel.barData.isEmpty {
                            let average = viewModel.barData.map(\.value).reduce(0, +) / Double(viewModel.barData.count)
                            RuleMark(
                                y: .value("Average", average)
                            )
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(Color.orange)
                        }

                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 10))
                    }
                    .chartYScale(domain: {
                        let values = viewModel.barData.map { $0.value }
                        if let max = values.max() {
                            return 0...(max + max * 0.1)
                        } else {
                            return 0...10
                        }
                    }())
                    .frame(height: 300)
                    .padding()
                    .background(Color.cardColor)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                if viewModel.selectedNutrient != .weight,
                   let goal = viewModel.goal,
                   !viewModel.barData.isEmpty {
                    
                    let average = viewModel.barData.map(\.value).reduce(0, +) / Double(viewModel.barData.count)
                    
                    HStack {
                        Text("Goal: ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        +
                        Text("\(Int(goal))")
                            .font(.caption)
                            .foregroundColor(Color.primaryGreen)
                        
                        Spacer()
                        
                        Text("Average: ")
                            .font(.caption)
                            .foregroundColor(.gray)
                        +
                        Text("\(Int(average))")
                            .font(.caption)
                            .foregroundColor(Color.orange)
                    }
                    .padding()
                    .background(Color.cardColor)
                    .cornerRadius(16)
                    .padding(.horizontal)}
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 365 Days' Summary")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    if let avg = statViewModel.averageData {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Average Steps:", systemImage: "figure.walk")
                                Spacer()
                                Text("\(Int(avg.stepCount))")
                                    .foregroundColor(.blue)
                            }

                            HStack {
                                Label("Average Calories Burnt:", systemImage: "flame")
                                Spacer()
                                Text("\(Int(avg.activeCalories)) kcal")
                                    .foregroundColor(.red)
                            }

                            HStack {
                                Label("Average Exercise:", systemImage: "figure.strengthtraining.traditional")
                                Spacer()
                                Text("\(Int(avg.exerciseMinutes)) min")
                                    .foregroundColor(.orange)
                            }

                            HStack {
                                Label("Average Sleep:", systemImage: "bed.double")
                                Spacer()
                                Text(String(format: "%.1f h", avg.sleepHours))
                                    .foregroundColor(.purple)
                            }

                            let avgCalories = viewModel.averageCaloriesLastYear()
                            HStack {
                                Label("Average Calorie Intake:", systemImage: "fork.knife")
                                Spacer()
                                Text("\(Int(avgCalories)) kcal")
                                    .foregroundColor(.green)
                            }

                            
                        }
                        .padding()
                        .background(Color.cardColor)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        ProgressView()
                            .padding()
                    }
                }

            }
            .padding(.top)
            
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .onChange(of: viewModel.selectedNutrient) { _, _ in
            viewModel.loadData()
        }
        .onChange(of: viewModel.selectedRange) { _, _ in
            viewModel.loadData()
        }
        .onAppear {
            viewModel.loadData()
        }
        .onAppear {
            statViewModel.loadHealthData()
        }
        
    }
}

