//
//  NutrientCard.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//
import SwiftUI

struct NutrientCard: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    let systemIconName: String
    
    // Automatický výpočet procenta
    private var percent: CGFloat {
        guard total > 0 else { return 0 }
        return min(CGFloat(value / total), 1.0)
    }
    
    // Vypočítáme barvu indikátoru podle percent
    private var indicatorColor: Color {
        switch percent {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        case 0.66..<1:
            return .green
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 12) {
                Image(systemName: systemIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(color))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // KRUHOVÝ PROGRESS
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                Circle()
                    .trim(from: 0.0, to: percent)
                    .stroke(indicatorColor, lineWidth: 10)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 60, height: 60)
            .padding(.bottom, 8)
            
            // HODNOTY
            Text(String(format: "%.1fg", value))
                .bold()
            Text(String(format: "%.1fg", total))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

import SwiftUI

struct PlaceholderCard: View {
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.orange))
                    
                    Text("Soon...")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                ZStack {
                    // Dummy progress circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    Circle()
                        .trim(from: 0.0, to: 0.7)
                        .stroke(Color.green.opacity(0.6), lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 60, height: 60)
                .padding(.bottom, 8)
                
                Text("0")
                    .bold()
                    .foregroundColor(.clear)
                Text("...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.cardColor)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .blur(radius: 6)
            
            // Lock icon centered over blurred card
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
        }
    }
}


