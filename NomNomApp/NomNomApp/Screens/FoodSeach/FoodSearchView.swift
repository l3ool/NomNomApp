//
//  FoodSearchView.swift
//  NomNomApp
//
//  Created by Vendelín Motyčka on 17.06.2025.
//

import SwiftUI

struct FoodSearchView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = FoodSearchViewModel()
    @State private var isShowingBarcodeScanner = false
    @State private var selectedFoodForDetail: FoodSearchResult? = nil

    enum ActiveSheet: Identifiable {
        case imagePicker, manualAdd
        var id: Int { hashValue }
    }
    @State private var activeSheet: ActiveSheet?
    
    let dataManager: CoreDataManager
    let homeViewModel: HomePageViewModel
    
    init(dataManager: CoreDataManager, homeViewModel: HomePageViewModel) {
        _viewModel = StateObject(wrappedValue: FoodSearchViewModel())
        self.dataManager = dataManager
        self.homeViewModel = homeViewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search for food", text: $viewModel.searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Spacer()

                    Button {
                        activeSheet = .manualAdd
                    } label: {
                        Image(systemName: "plus.circle")
                    }

                    Button {
                        activeSheet = .imagePicker
                    } label: {
                        Image(systemName: "camera")
                    }

                    Button {
                        isShowingBarcodeScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                }
                .padding()
                .background(Color.cardColor)
                .cornerRadius(12)
                .padding(.horizontal)

                List(viewModel.results) { food in
                    NavigationLink(
                        destination: MealDetailView(
                            viewModel: MealDetailViewModel(
                                food: food,
                                dataManager: dataManager,
                                homeViewModel: homeViewModel
                            )
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text(food.name)
                                .font(.headline)
                            Text(food.shortDescription)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Skrytý NavigationLink pro automatickou navigaci po načtení barcode výsledku
                NavigationLink(
                    destination: Group {
                        if let food = selectedFoodForDetail {
                            MealDetailView(
                                viewModel: MealDetailViewModel(
                                    food: food,
                                    dataManager: dataManager,
                                    homeViewModel: homeViewModel
                                )
                            )
                        }
                    },

                    isActive: Binding(
                        get: { selectedFoodForDetail != nil },
                        set: { if !$0 { selectedFoodForDetail = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("Search Food")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancel") {
                    dismiss()
                }
            )
        }
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.search()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .imagePicker:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    ImagePicker(sourceType: .camera, image: $viewModel.selectedImage)
                } else {
                    Text("Camera not available on this device.")
                }
            case .manualAdd:
                MealAddingView(
                    viewModel: MealAddingViewModel(dataManager: dataManager)
                )
            }
        }
        .sheet(isPresented: $isShowingBarcodeScanner) {
            BarcodeScannerView { scannedCode in
                isShowingBarcodeScanner = false
                if let code = scannedCode {
                    viewModel.searchByBarcode(code)
                }
            }
        }
        .onDisappear {
            homeViewModel.loadProfile()
            homeViewModel.loadMealsForSelectedDay()
        }
        .onChange(of: viewModel.selectedImage) { _, _ in
            viewModel.processSelectedImage()
        }
        .onReceive(viewModel.$selectedFoodForDetail) { food in
            selectedFoodForDetail = food
        }
    }
}
