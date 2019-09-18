//
//  Keyframe.swift
//  Delight
//
//  Created by Hector Matos on 9/28/18.
//

import Foundation

public protocol Keyframe: class, Hashable {
    associatedtype AnimationInstance: Animation
    associatedtype KeyframeValueProvider: ValueProvider where KeyframeValueProvider.Value == AnimationInstance.Value

    var timing: KeyframeTiming<AnimationInstance.Value.Progression> { get }
    var valueProvider: KeyframeValueProvider { get }
    var animation: AnimationInstance { get }
}

extension Keyframe {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.timing.overlaps(rhs.timing)
    }
}
