
//
//  LayerValueProviderr.swift
//  Delight
//
//  Created by Hector Matos on 10/1/18.
//

import Foundation

class LayerValueProvider<T: Animatable>: ValueProvider {
    let start: T
    var end: T

    private var shouldCommit: Bool = true
    private let toValueFunction: () -> T

    init(valueProvider: @escaping () -> T) {
        start = valueProvider()
        end = start
        toValueFunction = valueProvider
    }

    func commitValues() {
        guard shouldCommit else { return }
        shouldCommit = false

        end = toValueFunction()
    }
}
