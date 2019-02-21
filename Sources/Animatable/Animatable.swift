//
//  Animatable.swift
//  Utilities
//
//  Created by Hector Matos on 03/08/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

public protocol Animatable {
    associatedtype Value: Animatable where Value.Progression == Progression, Self == Value
    associatedtype Progression: BinaryFloatingPoint & Animatable where Progression.Stride == Progression

    func lerp(to value: Value, with progression: Progression) -> Value
}

extension Float: Animatable {}
extension Double: Animatable {}

extension Animatable where Self: BinaryFloatingPoint {
    public func lerp(to value: Self, with progress: Self) -> Self {
        return self + (value - self) * progress
    }
}
