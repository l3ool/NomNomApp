//
//  Colors.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 11.06.2025.
//

import SwiftUI

// HEX inicializátor pro Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// Definované barvy pro appku
extension Color {
    static let primaryGreen = Color(hex: "#14AD00")
    static let grayText = Color(hex: "#5E5E5E")
    static let backgroundColor = Color(hex: "#D9D9D9")
    static let cardColor = Color(hex: "#EAEAEA")
}
