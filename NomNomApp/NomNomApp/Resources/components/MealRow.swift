//
//  MealRow.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//
import SwiftUI

struct MealRow: View {
    let title: String
    let kcal: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(kcal) kcal")
        }
        .font(.body)
    }
}
