//
//  FatSecretAPI.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import Foundation
import UIKit
import Vision
import CoreML

class FatSecretAPI {
    static let shared = FatSecretAPI()
    
    private let clientID = "80b4fa6cfa384ff29accac05825e83d4"
    private let clientSecret = "6eb3c4837b7647fab3d8cfb7f4f47d31"
    private var token: String?

    func getAccessToken(completion: @escaping (String?) -> Void) {
        if let existingToken = token {
            completion(existingToken)
            return
        }

        let url = URL(string: "https://oauth.fatsecret.com/connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "grant_type=client_credentials&scope=basic barcode"
        request.httpBody = body.data(using: .utf8)

        let authString = "\(clientID):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Token error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Token response status: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Token request failed with status code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                print("No data received for token request")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let rawResponse = String(data: data, encoding: .utf8) ?? "nil"
            print("Token response: \(rawResponse)")

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    self?.token = accessToken // Store the token
                    DispatchQueue.main.async {
                        completion(accessToken)
                    }
                } else {
                    print("Failed to parse access_token from response")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("JSON parsing error for token: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    // Search food
    func searchFoods(query: String, completion: @escaping ([FoodSearchResult]) -> Void) {
        getAccessToken { token in
            guard let token = token else {
                completion([])
                return
            }
            
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "https://platform.fatsecret.com/rest/server.api?method=foods.search&format=json&search_expression=\(encodedQuery)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion([])
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Search error: \(error)")
                }

                if let response = response as? HTTPURLResponse {
                    print("Search response status: \(response.statusCode)")
                }

                if let data = data {
                    let raw = String(data: data, encoding: .utf8) ?? "nil"
                    print("Search raw response: \(raw)")
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let foodsDict = json["foods"] as? [String: Any],
                      let foods = foodsDict["food"] as? [[String: Any]] else {
                    print("Failed to parse search results")
                    completion([])
                    return
                }
                
                let results: [FoodSearchResult] = foods.compactMap { food in
                    if let name = food["food_name"] as? String,
                       let id = food["food_id"] as? String,
                       let description = food["food_description"] as? String {
                        
                        let unitLabel = (food["food_type"] as? String) ?? ""
                        
                        return FoodSearchResult(
                            foodID: id,
                            name: name,
                            description: description,
                            unitLabel: unitLabel
                        )
                    }
                    return nil
                }

                
                completion(results)
            }.resume()
        }
    }
    
    func getFoodDetails(foodID: String, completion: @escaping (FoodSearchResult?) -> Void) {
        getAccessToken { token in
            guard let token = token else {
                completion(nil)
                return
            }

            let urlString = "https://platform.fatsecret.com/rest/server.api?method=food.get.v2&format=json&food_id=\(foodID)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let foodWrapper = json["food"] as? [String: Any],
                      let name = foodWrapper["food_name"] as? String else {
                    completion(nil)
                    return
                }

                var unitLabel = ""
                var caloriesDetail: Double? = nil
                var proteinDetail: Double? = nil
                var fatDetail: Double? = nil
                var carbsDetail: Double? = nil
                let description = foodWrapper["food_description"] as? String ?? ""

                if let servings = foodWrapper["servings"] as? [String: Any] {
                    if let servingArray = servings["serving"] as? [[String: Any]] {
                        // Pokud je více servingů, vezmi první
                        let serving = servingArray.first!
                        unitLabel = serving["metric_serving_unit"] as? String ?? ""
                        caloriesDetail = Double(serving["calories"] as? String ?? "")
                        proteinDetail = Double(serving["protein"] as? String ?? "")
                        fatDetail = Double(serving["fat"] as? String ?? "")
                        carbsDetail = Double(serving["carbohydrate"] as? String ?? "")
                    } else if let serving = servings["serving"] as? [String: Any] {
                        // Pokud je jen jeden serving jako dictionary
                        unitLabel = serving["metric_serving_unit"] as? String ?? ""
                        caloriesDetail = Double(serving["calories"] as? String ?? "")
                        proteinDetail = Double(serving["protein"] as? String ?? "")
                        fatDetail = Double(serving["fat"] as? String ?? "")
                        carbsDetail = Double(serving["carbohydrate"] as? String ?? "")
                    }
                }

                let foodResult = FoodSearchResult(
                    foodID: foodID,
                    name: name,
                    description: description,
                    unitLabel: unitLabel,
                    caloriesDetail: caloriesDetail,
                    proteinDetail: proteinDetail,
                    fatDetail: fatDetail,
                    carbsDetail: carbsDetail
                )

                completion(foodResult)
            }.resume()
        }
    }

    // Search food by barcode
    func findFoodByBarcode(barcode: String, completion: @escaping ([FoodSearchResult]) -> Void) {
        getAccessToken { token in
            guard let token = token else {
                print("No access token for barcode search")
                completion([])
                return
            }
            
            let encodedBarcode = barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? barcode
            let urlString = "https://platform.fatsecret.com/rest/server.api?method=food.find_id_for_barcode&format=json&barcode=\(encodedBarcode)"
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL for barcode search")
                completion([])
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Barcode search error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let data = data else {
                    print("No data received for barcode search")
                    completion([])
                    return
                }
                
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Barcode search raw response: \(rawString)")
                }
                
                do {
                    guard
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let foodIdDict = json["food_id"] as? [String: Any],
                        let foodId = foodIdDict["value"] as? String else
                    {
                        print("Failed to parse food_id from barcode search response")
                        completion([])
                        return
                    }
                    
                    // Zavolej detail jídla s foodId pomocí veřejné metody
                    self.getFoodDetails(foodID: foodId) { foodResult in
                        if let foodResult = foodResult {
                            completion([foodResult])
                        } else {
                            completion([])
                        }
                    }
                    
                } catch {
                    print("JSON parsing error for barcode search: \(error.localizedDescription)")
                    completion([])
                }
            }.resume()
        }
    }
}


extension UIImage {
    func recognizeFoodObjects(completion: @escaping ([String]) -> Void) {
        guard let ciImage = CIImage(image: self) else {
            completion([])
            return
        }

        recognizeWithModel(modelName: "MyImageClassifier", ciImage: ciImage) { [weak self] firstResults in
            guard let self = self else { return }
            
            if !firstResults.isEmpty {
                completion(firstResults)
            } else {
                self.recognizeWithModel(modelName: "SeeFood", ciImage: ciImage) { secondResults in
                    if !secondResults.isEmpty {
                        completion(secondResults)
                    } else {
                        self.fallbackToAppleVision(ciImage: ciImage, completion: completion)
                    }
                }
            }
        }
    }
        // "SeeFood" a "MyImageClassifier" necommitovat
    private func recognizeWithModel(modelName: String, ciImage: CIImage, completion: @escaping ([String]) -> Void) {
        guard let mlModelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc"),
              let coreMLModel = try? MLModel(contentsOf: mlModelURL),
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            print("⚠️ Failed to load model \(modelName)")
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: visionModel) { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ \(modelName) error: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion([])
                    return
                }

                let foodNames = observations
                    .filter { $0.confidence > 0.6 }
                    .sorted(by: { $0.confidence > $1.confidence })
                    .map { $0.identifier }

                completion(foodNames)
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("⚠️ \(modelName) failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    private func fallbackToAppleVision(ciImage: CIImage, completion: @escaping ([String]) -> Void) {
        let request = VNClassifyImageRequest { request, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔍 Apple Vision error: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let observations = request.results as? [VNClassificationObservation] else {
                    completion([])
                    return
                }

                let foodKeywords = [
                    "apple", "banana", "orange",
                    "carrot", "broccoli", "potato",
                    "bread", "pizza", "sushi",
                    "chicken", "beef", "fish",
                    "rice", "pasta", "salad",
                    "egg", "cheese", "milk"
                ]


                let foodItems = observations
                    .filter { $0.confidence > 0.5 }
                    .filter { observation in
                        foodKeywords.contains { keyword in
                            observation.identifier.lowercased().contains(keyword)
                        }
                    }
                    .sorted { $0.confidence > $1.confidence }
                    .map { $0.identifier }

                completion(foodItems)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("🔍 Apple Vision failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
