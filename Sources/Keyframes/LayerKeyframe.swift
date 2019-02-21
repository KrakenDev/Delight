//
//  LayerAnimator.swift
//  Delight
//
//  Created by Hector Matos on 9/13/18.
//

import CoreGraphics
import Foundation
import ObjectiveC
import QuartzCore

class LayerKeyframe<T: Animatable>: Keyframe {
    let timing: KeyframeTiming<T.Progression>
    let valueProvider: LayerValueProvider<T>
    let hashValue: Int

    lazy var animation: LayerAnimation<T> = .init(from: self)

    init(valueProvider: LayerValueProvider<T>, hashValue: Int) {
        let parentContainer = AnimationQueue.enclosingAnimation()
        let parentTiming = parentContainer?.timing

        self.valueProvider = valueProvider
        self.timing = KeyframeTiming(
            curve: parentContainer?.timing.curve ?? .systemDefault,
            relativeStartTime: T.Progression(parentTiming?.relativeStartTime ?? 0.0),
            relativeDuration: T.Progression(parentTiming?.relativeDuration ?? 0.0),
            totalDuration: T.Progression(parentTiming?.totalDuration ?? 0.0)
        )
        self.hashValue = hashValue
    }
}
