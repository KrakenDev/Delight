//
//  CGColor+Animatable.swift
//  Delight
//
//  Created by Hector Matos on 9/28/18.
//

import CoreGraphics

extension CGColor: Animatable {
    public func lerp(to value: CGColor, with progress: Double) -> CGColor {
        guard let toColorSpace = value.colorSpace else { return value }
        let combined = zip(components ?? [], value.components ?? []).map { $0.0.lerp(to: $0.1, with: CGFloat(progress)) }
        return CGColor(colorSpace: toColorSpace, components: combined) ?? value
    }
}
