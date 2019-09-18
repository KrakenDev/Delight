//
//  Curve.swift
//  Delight
//
//  Created by Hector Matos on 9/13/18.
//

import UIKit

public enum TimingCurve {
    case inherited
    case systemDefault
    case cubic(CubicBezierCurve)
    case spring(SpringTiming)
}

extension TimingCurve: TimingParameters {
    public func progress(at time: Double) -> Progress<Double> {
        let bezierProgress = { (bezier: CubicBezierCurve) -> Progress<Double> in
            let progression = bezier.progress(at: time)
            return Progress(
                relativeTime: progression.relativeTime,
                relativeValue: progression.relativeValue
            )
        }

        switch self {
        case .inherited, .systemDefault:
            return bezierProgress(CubicBezierCurve(functionName: .default))
        case .cubic(let bezier):
            return bezierProgress(bezier)
        case .spring(let spring):
            let springProgress = spring.progress(at: time)
            return Progress(
                relativeTime: springProgress.relativeTime,
                relativeValue: springProgress.relativeValue
            )
        }
    }
}

// MARK: Convenience
extension CubicBezierCurve {
    public static let linear = CubicBezierCurve(functionName: .linear)
    public static let easeIn = CubicBezierCurve(functionName: .easeIn)
    public static let easeOut = CubicBezierCurve(functionName: .easeOut)
    public static let easeInEaseOut = CubicBezierCurve(functionName: .easeInEaseOut)

    public static let inherited = CubicBezierCurve(functionName: .default)
    public static let systemDefault = CubicBezierCurve(functionName: .default)

    public static let easeOutExpo = CubicBezierCurve(.init(x: 0.175, y: 0.885), .init(x: 0.320, y: 1.275))
    public static let easeOutBack = CubicBezierCurve(.init(x: 0.230, y: 1.000), .init(x: 0.470, y: 1.75))

    /**
     I Initially took the values from http://easings.net/#easeOutBack & then
     manipulated them with the tool at https://matthewlein.com/tools/ceaser
     for a more drastic bounce effect.
     */
    public static let easeOutBackDrastic = CubicBezierCurve(.init(x: 0.190, y: 1.000), .init(x: 0.220, y: 1.00))
}

extension TimingCurve: Equatable {
    public static func ==(lhs: TimingCurve, rhs: TimingCurve) -> Bool {
        switch (lhs, rhs) {
        case (.inherited, .inherited):
            return true
        case (.systemDefault, .systemDefault):
            return true
        case let (.cubic(lhsCurve), .cubic(rhsCurve)):
            return lhsCurve == rhsCurve
        case let (.spring(lhsSpring), .spring(rhsSpring)):
            return lhsSpring == rhsSpring
        default: return false
        }
    }
}
