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
    let hashValue: Int
    let timing: KeyframeTiming
    let valueProvider: LayerValueProvider<T>

    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }

    lazy var animation: LayerAnimation<T> = .init(from: self)

    init(valueProvider: LayerValueProvider<T>, hashValue: Int) {
        let parentContainer = AnimationQueue.enclosingAnimation()
        let parentTiming = parentContainer?.timing

        self.valueProvider = valueProvider
        self.timing = KeyframeTiming(
            curve: parentContainer?.timing.curve ?? .systemDefault,
            relativeStartTime: parentTiming?.relativeStartTime ?? 0.0,
            relativeDuration: parentTiming?.relativeDuration ?? 0.0,
            totalDuration: parentTiming?.totalDuration ?? 0.0
        )
        self.hashValue = hashValue
    }
}
