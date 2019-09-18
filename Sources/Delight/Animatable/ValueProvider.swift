//
//  ValueProvider.swift
//  Delight
//
//  Created by Hector Matos on 10/3/18.
//

import UIKit

public protocol ValueProvider: class, CustomStringConvertible {
    associatedtype Value

    var start: Value { get }
    var end: Value { get }

    func commitValues()
}

extension ValueProvider {
    public var description: String {
        return "Start: \(String(describing: start)), End: \(String(describing: end))"
    }
}

public class AnyValueProvider {
    private let getStartValue: () -> Any
    private let getEndValue: () -> Any
    private let commitValueBlock: () -> Void

    public init<T: ValueProvider>(_ provider: T) {
        getStartValue = { return provider.start }
        getEndValue = { return provider.end }
        commitValueBlock = provider.commitValues
    }
}

extension AnyValueProvider: ValueProvider {
    public var start: Any { return getStartValue() }
    public var end: Any { return getEndValue() }

    public func commitValues() {
        commitValueBlock()
    }
}
