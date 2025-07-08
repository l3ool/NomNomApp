//
//  StatisticsViewModel.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import Foundation
import Combine
struct DailyHealthData {
    let date: Date
    let activeCalories: Double
    let stepCount: Double
    let exerciseMinutes: Double
    let sleepHours: Double
}

class StatisticsViewModel: ObservableObject {
    @Published var dailyHealthData: [DailyHealthData] = []

    @Published var averageData: DailyHealthData?
    @Published var maxData: DailyHealthData?
    @Published var minData: DailyHealthData?
    
    @Published var topSleepDays: [Date] = []
    @Published var bottomSleepDays: [Date] = []
    @Published var topStepDays: [Date] = []
    @Published var bottomStepDays: [Date] = []
    @Published var topBurnDays: [Date] = []
    @Published var bottomBurnDays: [Date] = []

    func loadHealthData() {
        HealthManager.shared.requestAuthorization { success in
            guard success else {
                print("HealthKit authorization failed")
                return
            }

            let group = DispatchGroup()
            var results: [DailyHealthData] = []
            let dates = (0..<365).map { Calendar.current.date(byAdding: .day, value: -$0, to: Date())! }

            for date in dates {
                group.enter()
                HealthManager.shared.fetchDailyHealthData(for: date) { data in
                    results.append(data)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.dailyHealthData = results.sorted { $0.date < $1.date }
                self.computeStatistics()
            }
        }
    }

    private func computeStatistics() {
        guard !dailyHealthData.isEmpty else { return }

        // Mazani 0 zaznamu... mozna upravit??
        let activeCaloriesData = dailyHealthData.filter { $0.activeCalories > 0 }
        let stepCountData = dailyHealthData.filter { $0.stepCount > 0 }
        let exerciseMinutesData = dailyHealthData.filter { $0.exerciseMinutes > 0 }
        let sleepHoursData = dailyHealthData.filter { $0.sleepHours > 0 }

        func average(of data: [Double]) -> Double {
            guard !data.isEmpty else { return 0 }
            return data.reduce(0, +) / Double(data.count)
        }

        let avg = DailyHealthData(
            date: Date(),
            activeCalories: average(of: activeCaloriesData.map { $0.activeCalories }),
            stepCount: average(of: stepCountData.map { $0.stepCount }),
            exerciseMinutes: average(of: exerciseMinutesData.map { $0.exerciseMinutes }),
            sleepHours: average(of: sleepHoursData.map { $0.sleepHours })
        )
        self.averageData = avg

        func maxValue(_ data: [DailyHealthData], key: KeyPath<DailyHealthData, Double>) -> Double {
            data.max(by: { $0[keyPath: key] < $1[keyPath: key] })?[keyPath: key] ?? 0
        }

        func minValue(_ data: [DailyHealthData], key: KeyPath<DailyHealthData, Double>) -> Double {
            data.min(by: { $0[keyPath: key] < $1[keyPath: key] })?[keyPath: key] ?? 0
        }

        self.maxData = DailyHealthData(
            date: Date(),
            activeCalories: maxValue(activeCaloriesData, key: \.activeCalories),
            stepCount: maxValue(stepCountData, key: \.stepCount),
            exerciseMinutes: maxValue(exerciseMinutesData, key: \.exerciseMinutes),
            sleepHours: maxValue(sleepHoursData, key: \.sleepHours)
        )

        self.minData = DailyHealthData(
            date: Date(),
            activeCalories: minValue(activeCaloriesData, key: \.activeCalories),
            stepCount: minValue(stepCountData, key: \.stepCount),
            exerciseMinutes: minValue(exerciseMinutesData, key: \.exerciseMinutes),
            sleepHours: minValue(sleepHoursData, key: \.sleepHours)
        )
    }
    
    func computePercentileDays() {
           guard !dailyHealthData.isEmpty else { return }

           func topAndBottom20PercentDates(by keyPath: KeyPath<DailyHealthData, Double>) -> (top: [Date], bottom: [Date]) {
               let sorted = dailyHealthData.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
               let count = sorted.count
               let thresholdCount = max(1, Int(Double(count) * 0.2))

               let bottom = sorted.prefix(thresholdCount).map { $0.date }
               let top = sorted.suffix(thresholdCount).map { $0.date }

               return (Array(top), Array(bottom))
           }

           (topSleepDays, bottomSleepDays) = topAndBottom20PercentDates(by: \.sleepHours)
           (topStepDays, bottomStepDays) = topAndBottom20PercentDates(by: \.stepCount)
           (topBurnDays, bottomBurnDays) = topAndBottom20PercentDates(by: \.activeCalories)
       }
}
