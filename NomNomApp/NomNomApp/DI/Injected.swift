//
//  Injected.swift
//  NomNomApp
//
//  Created by Ivan Kolesnychenko on 10.06.2025.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T

    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
