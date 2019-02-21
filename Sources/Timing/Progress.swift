//
//  Progress.swift
//  Delight
//
//  Created by Hector Matos on 11/17/18.
//

import Foundation

public struct Progress<T: BinaryFloatingPoint>: TimingProgress where T.Stride == T {
    public let relativeTime: T
    public let relativeValue: T

    public static func start() -> Progress<T> {
        return Progress(relativeTime: 0.0, relativeValue: 0.0)
    }
    public static func end() -> Progress<T> {
        return Progress(relativeTime: 1.0, relativeValue: 1.0)
    }

    init(relativeTime: T, relativeValue: T) {
        self.relativeTime = relativeTime
        self.relativeValue = relativeValue
    }
}
