//
//  HealthManager.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//


import HealthKit

class HealthManager {
    static let shared = HealthManager()
    private let healthStore = HKHealthStore()

    // Typy, ke kterým chceme přístup
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    ]

    // Požádej o oprávnění
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            completion(success)
        }
    }

    // MARK: - Načtení aktivní energie spálené za den (kcal)
    func fetchActiveEnergyBurned(for date: Date, completion: @escaping (Double) -> Void) {
        fetchSumQuantity(for: .activeEnergyBurned, unit: .kilocalorie(), date: date, completion: completion)
    }

    // MARK: - Načtení počtu kroků za den
    func fetchStepCount(for date: Date, completion: @escaping (Double) -> Void) {
        fetchSumQuantity(for: .stepCount, unit: HKUnit.count(), date: date, completion: completion)
    }

    // MARK: - Načtení doby cvičení za den (v minutách)
    func fetchExerciseTime(for date: Date, completion: @escaping (Double) -> Void) {
        fetchSumQuantity(for: .appleExerciseTime, unit: HKUnit.minute(), date: date, completion: completion)
    }

    // MARK: - Načtení délky spánku za noc (v hodinách)
    func fetchSleepAnalysis(for date: Date, completion: @escaping (Double) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: [])

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {
                print("Sleep query error: \(error!)")
                completion(0)
                return
            }

            var sleepSeconds = 0.0
            if let samples = samples as? [HKCategorySample] {
                for sample in samples {
                    // Spánek je kategorizován hodnotou .asleep(1), ostatní ignorujeme
                    if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        sleepSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
            }

            let sleepHours = sleepSeconds / 3600
            completion(sleepHours)
        }

        healthStore.execute(query)
    }

    // MARK: - Helper funkce pro sumu quantity
    private func fetchSumQuantity(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, date: Date, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard error == nil else {
                print("Error fetching \(identifier.rawValue): \(error!)")
                completion(0)
                return
            }

            let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completion(sum)
        }

        healthStore.execute(query)
    }
    
    func fetchDailyHealthData(for date: Date, completion: @escaping (DailyHealthData) -> Void) {
        let group = DispatchGroup()

        var activeCalories: Double = 0
        var stepCount: Double = 0
        var exerciseMinutes: Double = 0
        var sleepHours: Double = 0

        group.enter()
        fetchActiveEnergyBurned(for: date) {
            activeCalories = $0
            group.leave()
        }

        group.enter()
        fetchStepCount(for: date) {
            stepCount = $0
            group.leave()
        }

        group.enter()
        fetchExerciseTime(for: date) {
            exerciseMinutes = $0
            group.leave()
        }

        group.enter()
        fetchSleepAnalysis(for: date) {
            sleepHours = $0
            group.leave()
        }

        group.notify(queue: .main) {
            let data = DailyHealthData(date: date,
                                       activeCalories: activeCalories,
                                       stepCount: stepCount,
                                       exerciseMinutes: exerciseMinutes,
                                       sleepHours: sleepHours)
            completion(data)
        }
    }

}
