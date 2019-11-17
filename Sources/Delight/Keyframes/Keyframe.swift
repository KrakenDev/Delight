//
//  Keyframe.swift
//  Delight
//
//  Created by Hector Matos on 9/28/18.
//

import CoreGraphics

public protocol Keyframe: class, Hashable, Comparable {
    associatedtype AnimationInstance: Animation
    associatedtype KeyframeValueProvider: ValueProvider where KeyframeValueProvider.Value == AnimationInstance.Value

    var timing: KeyframeTiming<AnimationInstance.Value.Progression> { get }
    var valueProvider: KeyframeValueProvider { get }
    var animation: AnimationInstance { get }
}

extension Keyframe {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.timing.relativeStartTime < rhs.timing.relativeStartTime
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.timing.overlaps(rhs.timing)
    }
}
