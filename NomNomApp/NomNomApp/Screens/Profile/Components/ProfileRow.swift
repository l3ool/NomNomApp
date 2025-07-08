//
//  ProfileRow.swift
//  NomNomApp
//
//  Created by Peter Machava on 20.06.2025.
//

import SwiftUI

struct ProfileRow: View {
    var label: String
    var unit: String?
    @Binding var value: String
    
    var body: some View {
        HStack(){
            Text(label)
            Spacer()
            HStack(spacing: 5){
                TextField(label, text: $value)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                Text(unit ?? "")
                    .foregroundColor(.primaryGreen)
                    
            }
        }
    }
}
