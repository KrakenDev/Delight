import Foundation
import CoreGraphics
import QuartzCore

class KeyframeContainer: AnimationContainer {
    let timing: KeyframeTiming
    var isExecuting: Bool { return animationBlock != nil }

    private var parentContainer: AnimationContainer?
    private var keyframeFinalizers: [VoidBlock?] = []
    private(set) var animationBlock: AnimationBlock?

    init(with relativeStartTime: Double, relativeDuration: Double, curve: TimingCurve, animations: @escaping AnimationBlock) {
        animationBlock = animations
        timing = KeyframeTiming(
            curve: curve,
            relativeStartTime: relativeStartTime,
            relativeDuration: relativeDuration,
            totalDuration: CATransaction.animationDuration()
        )
    }

    func addAnimation<T: Keyframe>(for keyframe: T?, using animationFromRelatedKeyframes: @escaping AnimationExecution<T>) {
        parentContainer?.addAnimation(for: keyframe, using: animationFromRelatedKeyframes)
        keyframeFinalizers.append(keyframe?.valueProvider.commitValues)
    }

    func nest(inside parent: AnimationContainer?) {
        guard let parent = parent, !(parent is KeyframeContainer) else { return }

        parentContainer = parent
        timing.relativeStartTime = parent.timing.relativeStartTime + (timing.relativeStartTime * parent.timing.relativeDuration)
        timing.relativeDuration = timing.relativeDuration * parent.timing.relativeDuration
        timing.totalDuration = parent.timing.totalDuration
        timing.curve = (timing.curve == .inherited) ? parent.timing.curve : timing.curve

        animationBlock?()
        animationBlock = nil

        keyframeFinalizers.compactMap(identity).forEach(execute)
    }
}

extension CALayer {
    open class func defaultAction(forKey event: String) -> CAAction? {
        return nil
    }
}
