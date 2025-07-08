//
//  CircularProgressView.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//
import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat  // hodnota mezi 0 a 1
    let valueText: String
    let totalText: String
    
    private var indicatorColor: Color {
        switch progress {
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
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(indicatorColor, lineWidth: 12)
                .rotationEffect(.degrees(-90))
            VStack {
                Text(valueText)
                    .font(.title)
                    .bold()
                Text(totalText)
                    .font(.caption)
            }
        }
        .frame(width: 140, height: 140)
    }
}
