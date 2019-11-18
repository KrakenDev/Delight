//
//  Animation.swift
//  Delight
//
//  Created by Hector Matos on 02/14/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import Foundation

/**
 * Representation of a regular UIKit parent animation such as the
 * ones created by +[UIView animateWithDuration:animations:completion:] &&
 * +[UIView animateKeyframesWithDelay:duration:options:animations:completion:]
 */
class RegularContainer: AnimationContainer {
    let timing: KeyframeTiming
    var isExecuting: Bool {
        return animationBlock != nil
    }

    private var animationBlock: AnimationBlock?
    private var animations: [Int : DeferredAnimation] = [:]

    init(withDelay delay: Double, duration: Double, curve: TimingCurve, animations: @escaping AnimationBlock) {
        animationBlock = animations

        /**
         * To support delays, we need to create CAKeyframeAnimations that last for the entire
         * duration of the animation (including its delay). Then we need to update the container to
         * start at a relative start time to the entirety of the animation's inherited duration.
         */
        let totalDuration = delay + duration
        timing = KeyframeTiming(
            curve: curve,
            relativeStartTime: delay / totalDuration,
            relativeDuration: duration / totalDuration,
            totalDuration: totalDuration
        )
    }

    func addAnimation<T: Keyframe>(for keyframe: T?, using animationFromRelatedKeyframes: @escaping AnimationExecution<T>) {
        guard let keyframe = keyframe else { return }

        var newKeyframes = animations[keyframe.hashValue]?.keyframes as? [T] ?? []

        if let mostRecentKeyframe = newKeyframes.last, mostRecentKeyframe == keyframe {
            newKeyframes.removeLast()
        }

        newKeyframes.append(keyframe)

        animations[keyframe.hashValue] = DeferredAnimation(
            keyframes: newKeyframes,
            cachedCommits: { newKeyframes.map(\.valueProvider).map(T.KeyframeValueProvider.commitValues).forEach(execute) },
            cachedAnimations: newKeyframes.deferred(animationFromRelatedKeyframes)
        )
    }

    func nest(inside container: AnimationContainer?) {
        /**
         * Since we are nesting inside of a container, this is a great place to update
         * our animation curve if we've explicitly requested to inherit an animation curve.
         */
        let inheritedCurve = container?.timing.curve ?? .systemDefault
        timing.curve = (timing.curve == .inherited) ? inheritedCurve : timing.curve

        animationBlock?()
        animationBlock = nil

        animations.values.map(\.cachedCommits).forEach(execute)
    }

    func executeAnimations() {
        animations.values.map(\.cachedAnimations).forEach(execute)
    }
}
