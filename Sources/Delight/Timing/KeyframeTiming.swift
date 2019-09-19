//
//  InterpolatedAnimation.swift
//  Delight
//
//  Created by Hector Matos on 02/14/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import Foundation

public class KeyframeTiming<T: BinaryFloatingPoint>: TimingParameters, Overlappable {
    public var curve: TimingCurve
    public var relativeStartTime: T
    public var relativeDuration: T
    public var totalDuration: T
    public var range: Range<T> {
        return relativeStartTime..<(relativeStartTime + relativeDuration)
    }

    public init(curve: TimingCurve = .systemDefault, relativeStartTime: T = 0.0, relativeDuration: T = 1.0, totalDuration: T = 0.0) {
        self.curve = curve
        self.relativeStartTime = relativeStartTime
        self.relativeDuration = relativeDuration
        self.totalDuration = totalDuration
    }

    public func overlaps(_ overlappable: KeyframeTiming<T>) -> Bool {
        return range.overlaps(overlappable.range)
    }

    public func progress(at time: T) -> Progress<T> {
        let curveProgression = curve.progress(at: Double(time))
        return Progress(
            relativeTime: T(curveProgression.relativeTime),
            relativeValue: T(curveProgression.relativeValue)
        )
    }

    public static func == (lhs: KeyframeTiming<T>, rhs: KeyframeTiming<T>) -> Bool {
        return lhs.range == rhs.range && lhs.curve == rhs.curve && lhs.totalDuration == rhs.totalDuration && lhs.relativeDuration == rhs.relativeDuration && lhs.relativeStartTime == rhs.relativeStartTime
    }
}
