import Foundation
import QuartzCore

@objc public class AnimationQueue: NSObject {
    typealias QueuedAnimation = AnimationContainer

    private var backingQueue: [QueuedAnimation] = []
    private var previousQueue: AnimationQueue?

    private static var queueStack: [AnimationQueue] = []

    /**
     * Returns the most recently enqueued animation container that hasn't finished capturing
     * all of its animations yet and that hasn't been flushed with a call to commitAnimations.
     *
     * This enclosing animation is the equivalent of a block that hasn't reached its last line of
     * code yet.
     */
    public static func enclosingAnimation() -> AnimationContainer? {
        /**
         * +[UIView inheritedAnimationDuration] only ever returns non zero value when called
         * within the body of an animation block. We don't want to interfere with explicitly
         * called animation blocks so let's not bother returning an enclosing animation. This
         * will prevent anyone adding any object to any queued animation's animator array.
         */
        guard View.inheritedAnimationDuration == 0.0 else { return nil }
        return currentQueue?.currentAnimation ?? currentQueue?.parentAnimation
    }

    /**
     * Starts monitoring for animations being enqueued.
     * API should be used like you would use CATransaction.begin()
     */
    static func begin() {
        if queueStack.isEmpty {
            prepare()
        }

        let newQueue = AnimationQueue()
        newQueue.previousQueue = queueStack.last
        queueStack.append(newQueue)
    }

    static func enqueue(_ animation: AnimationContainer) {
        guard let currentBackingQueue = currentQueue?.backingQueue, (animation is RegularContainer) || !currentBackingQueue.isEmpty else {
            fatalError("Attempted to call addKeyframe(withDuration:relativeStartTime:relativeDuration:) outside an animate(withDuration:animations:) or animateKeyframes(withDuration:animations:) animations block ")
        }

        currentQueue?.backingQueue.append(animation)
        animation.nest(inside: currentQueue?.parentAnimation)
    }

    /**
     * Stops monitoring for animations being enqueued and executes the animations enqueued since the last call to AnimationQueue.begin().
     * API should be used like you would use CATransaction.commit()
     */
    static func commit() {
        currentQueue?.backingQueue.forEach {
            $0.executeAnimations()
        }

        queueStack.removeLast()

        if queueStack.isEmpty {
            cleanup()
        }
    }

    private static func prepare() {
        let oldActionForKey = #selector(CALayer.action(forKey:))
        let newActionForKey = #selector(CALayer.delightfulAction(forKey:))
        swizzle(CALayer.self, .instance, method: oldActionForKey, with: newActionForKey)
    }

    private static func cleanup() {
        let oldActionForKey = #selector(CALayer.delightfulAction(forKey:))
        let newActionForKey = #selector(CALayer.action(forKey:))
        swizzle(CALayer.self, .instance, method: oldActionForKey, with: newActionForKey)
    }
}

// MARK: - Convenience
extension AnimationQueue {
    private var parentIsExecuting: Bool {
        return backingQueue.first?.isExecuting ?? false
    }

    private var parentAnimation: QueuedAnimation? {
        return parentIsExecuting ? backingQueue.first : previousQueue?.parentAnimation
    }

    private var currentIsExecuting: Bool {
        return backingQueue.last?.isExecuting ?? false
    }

    private var currentAnimation: QueuedAnimation? {
        return currentIsExecuting ? backingQueue.last : nil
    }

    private static var currentQueue: AnimationQueue? {
        return queueStack.last
    }
}
