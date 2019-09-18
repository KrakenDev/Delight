//
//  QuartzCore+Animatable.swift
//  Delight
//
//  Created by Hector Matos on 10/15/18.
//

import Foundation
import UIKit

extension CGFloat: Animatable {}

extension ControlPoint: KeyPathProvider {
    public static let keyPaths = [\x, \y]
}

extension CGPoint: KeyPathProvider {
    public static let keyPaths = [\x, \y]
}

extension CGSize: Animatable {
    // Impossible to have negative sizes
    public func lerp(to value: CGSize, with progression: Double) -> CGSize {
        return CGSize(
            width: max(0.0, width.lerp(to: value.width, with: CGFloat(progression))),
            height: max(0.0, height.lerp(to: value.height, with: CGFloat(progression)))
        )
    }
}

extension CGRect: Animatable {
    public func lerp(to value: CGRect, with progression: Double) -> CGRect {
        return CGRect(
            origin: origin.lerp(to: value.origin, with: CGFloat(progression)),
            size: size.lerp(to: value.size, with: progression)
        )
    }
}

extension CGVector: KeyPathProvider {
    public static let keyPaths = [\dx, \dy]
}

extension CGAffineTransform: KeyPathProvider {
    public static let keyPaths = [\a, \b, \c, \d, \tx, \ty]
}

extension CATransform3D: KeyPathProvider {
    public static let keyPaths = [
        \m11, \m12, \m13, \m14,
        \m21, \m22, \m23, \m24,
        \m31, \m32, \m33, \m34,
        \m41, \m42, \m43, \m44
    ]
}
