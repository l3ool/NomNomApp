import Foundation

class MealDetailViewModel: ObservableObject {
    @Published var mealType: MealType = .Breakfast
    @Published var mealDate: Date = Date()
    @Published var mealName: String
    @Published var amount: Int = 1
    @Published var unitLabel: String

    private let dataManager: CoreDataManager
    private let homeViewModel: HomePageViewModel?

    let calories: Double?
    let protein: Double?
    let fat: Double?
    let carbs: Double?

    // MARK: - Init
    init(food: FoodSearchResult,
         dataManager: CoreDataManager,
         homeViewModel: HomePageViewModel? = nil) {
        self.dataManager = dataManager
        self.homeViewModel = homeViewModel

        self.mealName = food.name
        self.calories = food.caloriesDetail ?? food.calories
        self.protein = food.proteinDetail ?? food.protein
        self.fat = food.fatDetail ?? food.fat
        self.carbs = food.carbsDetail ?? food.carbs

        let desc = food.description
        if let range = desc.range(of: " - Calories:") {
            self.unitLabel = desc[..<range.lowerBound]
                .replacingOccurrences(of: "Per ", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            self.unitLabel = "unit"
        }
    }

    // MARK: - Record Meal
    func recordMeal() {
        let context = dataManager.context

        let day = getOrCreateDay(for: mealDate)

        let newMeal = MealEntity(context: context)
        newMeal.id = UUID()
        newMeal.name = mealName
        newMeal.mealType = mealType.rawValue
        newMeal.servingSize = Double(amount)
        newMeal.servingUnit = unitLabel
        newMeal.calories = totalCalories
        newMeal.proteins = totalProtein
        newMeal.fats = totalFat
        newMeal.carbs = totalCarbs
        newMeal.isCustom = false

        dataManager.addMeal(meal: newMeal, day: day)

        // Optional: update UI
        homeViewModel?.loadProfile()
        homeViewModel?.loadMealsForSelectedDay()
    }

    // MARK: - Helpers
    private func getOrCreateDay(for date: Date) -> DayMyEntity {
        if let existing = dataManager.fetchDay(for: date) {
            return existing
        }

        let newDay = DayMyEntity(context: dataManager.context)
        newDay.id = UUID()
        newDay.date = date
        return newDay
    }

    // MARK: - Calculated totals
    var totalCalories: Double {
        (calories ?? 0) * Double(amount)
    }

    var totalProtein: Double {
        (protein ?? 0) * Double(amount)
    }

    var totalFat: Double {
        (fat ?? 0) * Double(amount)
    }

    var totalCarbs: Double {
        (carbs ?? 0) * Double(amount)
    }
}
