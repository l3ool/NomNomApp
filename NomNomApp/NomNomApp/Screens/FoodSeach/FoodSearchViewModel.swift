//
//  FoodSearchViewModel.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import Foundation
import UIKit
import Combine

class FoodSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [FoodSearchResult] = []
    @Published var presentImagePicker = false
    @Published var selectedImage: UIImage?
    @Published var selectedFoodForDetail: FoodSearchResult? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if !text.isEmpty {
                    self.search()
                } else {
                    self.results = []
                }
            }
            .store(in: &cancellables)
    }

    func search() {
        print("🔍 Searching for '\(searchText)'")
        FatSecretAPI.shared.searchFoods(query: searchText) { [weak self] foods in
            DispatchQueue.main.async {
                self?.results = foods
            }
        }
    }

    func searchByBarcode(_ barcode: String) {
        FatSecretAPI.shared.findFoodByBarcode(barcode: barcode) { foods in
            DispatchQueue.main.async {
                if !foods.isEmpty {
                    self.results = foods
                    self.selectedFoodForDetail = foods.first
                } else {
                    print("❌ No food found for barcode \(barcode)")
                    self.results = []
                    self.selectedFoodForDetail = nil
                }
            }
        }
    }


    func fetchFoodDetail(foodId: String) {
        FatSecretAPI.shared.getFoodDetails(foodID: foodId) { [weak self] foodResult in
            DispatchQueue.main.async {
                guard let foodResult = foodResult else {
                    print("❌ Failed to fetch food details for id \(foodId)")
                    return
                }
                self?.results = [foodResult]
                self?.selectedFoodForDetail = foodResult
            }
        }
    }



    func processSelectedImage() {
        guard let image = selectedImage else { return }

        image.recognizeFoodObjects { [weak self] (foodNames: [String]) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let firstFood = foodNames.first {
                    let cleanedFood = firstFood
                        .replacingOccurrences(of: "_", with: " ")
                        .replacingOccurrences(of: "\\d+", with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespaces)

                    print("🍎 Recognized food object: \(cleanedFood)")
                    self.searchText = cleanedFood
                    self.search()
                } else {
                    print("❌ No recognizable food objects found")
                    self.results = []
                }
            }
        }

    }
}



struct FoodIdResponse: Decodable {
    struct FoodIdValue: Decodable {
        let value: String
    }
    let food_id: FoodIdValue?
}
