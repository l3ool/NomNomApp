//
//  IntroPage.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import SwiftUI

struct PageView: View {
    var imageName: String
    var title: String
    var description: String
        

    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            Text(title)
                .font(.largeTitle)
                .bold()
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Text("Swipe to continue ->")
                .font(.footnote)
                .foregroundColor(.primaryGreen)
        }
        .padding()
    }
}
