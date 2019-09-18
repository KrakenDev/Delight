//
//  CALayer+Interception.swift
//  Delight
//
//  Created by Hector Matos on 10/15/18.
//

import UIKit

extension CALayer {
    @objc open func delightfulAction(forKey keyPath: String) -> CAAction? {
        struct FailedEnqueue: Error { }
        guard let container = AnimationQueue.enclosingAnimation(),
            let oldValue = value(forKey: keyPath)
            else { return delightfulAction(forKey: keyPath) }

        var hasher = Hasher()
        hasher.combine(self)
        hasher.combine(keyPath)

        let hashValue = hasher.finalize()

        func enqueueing<T: Animatable>(with possibleValue: T?) throws {
            guard let value = possibleValue else { throw FailedEnqueue() }

            let valueProvider = LayerValueProvider { [weak self] in
                self?.value(forKey: keyPath) as? T ?? value
            }

            let keyframe = LayerKeyframe<T>(valueProvider: valueProvider, hashValue: hashValue)
            container.addAnimation(for: keyframe) { [weak self] relatedKeyframes in
                let animation = CAKeyframeAnimation(keyPath: keyPath)
                animation.duration = container.timing.totalDuration

                animation.values = relatedKeyframes.reduce([T]()) {
                    return $0 + $1.animation.values.dropLast()
                }
                animation.keyTimes = relatedKeyframes.reduce([NSNumber]()) {
                    return $0 + $1.animation.keyTimes
                        .map(Double.init)
                        .map(NSNumber.init(value:))
                        .dropLast()
                }
                
                self?.add(animation, forKey: keyPath)
            }
        }

        try? enqueueing(with: oldValue as? Double)
        try? enqueueing(with: oldValue as? ControlPoint)
        try? enqueueing(with: oldValue as? CGPoint)
        try? enqueueing(with: oldValue as? CGSize)
        try? enqueueing(with: oldValue as? CGRect)
        try? enqueueing(with: oldValue as? CGVector)
        try? enqueueing(with: oldValue as? CGAffineTransform)
        try? enqueueing(with: oldValue as? CATransform3D)
        try? enqueueing(with: oldValue as? Double)
        try? enqueueing(with: oldValue as? Float)
        try? enqueueing(with: CGPath.value(from: oldValue))
        try? enqueueing(with: CGColor.value(from: oldValue))

        return delightfulAction(forKey: keyPath)
    }
}
