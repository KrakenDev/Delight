public protocol Displayable {
    static var maxFPS: Int { get }
    static var inheritedAnimationDuration: Double { get }

    static func setAnimationDuration(_ duration: Double)
    static func animate(withDuration duration: Double, delay: Double, curve: TimingCurve, animations: @escaping AnimationBlock, completion: AnimationCompletion?)
    static func animateKeyframes(withDuration duration: Double, delay: Double, curve: TimingCurve, animations: @escaping AnimationBlock, completion: AnimationCompletion?)

    static func addKeyframe(withRelativeStartTime frameStartTime: Double, relativeDuration frameDuration: Double, curve: TimingCurve, animations: @escaping AnimationBlock)
}

extension Displayable {
    public static var maxFPS: Int { 60 }
    public static func setAnimationDuration(_ duration: Double) {}
    public static func animate(withDuration duration: Double, delay: Double = 0.0, curve: TimingCurve, animations: @escaping AnimationBlock) {
        animate(withDuration: duration, delay: delay, curve: curve, animations: animations, completion: nil)
    }

    public static func animate(withDuration duration: Double, delay: Double = 0.0, curve: TimingCurve, animations: @escaping AnimationBlock, completion: AnimationCompletion?) {
        perform(withDuration: duration, delay: delay, curve: curve, animations: animations, completion: completion)
    }

    public static func animateKeyframes(withDuration duration: Double, delay: Double = 0.0, curve: TimingCurve, animations: @escaping AnimationBlock) {
        animateKeyframes(withDuration: duration, delay: delay, curve: curve, animations: animations, completion: nil)
    }

    public static func animateKeyframes(withDuration duration: Double, delay: Double = 0.0, curve: TimingCurve, animations: @escaping AnimationBlock, completion: AnimationCompletion?) {
        perform(withDuration: duration, delay: delay, curve: curve, animations: animations, completion: completion)
    }

    static func perform(withDuration duration: Double, delay: Double, curve: TimingCurve, animations: @escaping AnimationBlock, completion: AnimationCompletion?) {
        /**
         * Make sure we aren't trying to attempt an animation that is faster than a frame.
         * One frame is an immediate update since there aren't enough frames to interpolate
         * values within an animation. So let's make sure we aren't forcing the system to do
         * an unnecessary animation.
         */
        guard !Transaction.disableActions && duration >= 1.0 / Double(maxFPS) else {
            return executeWithoutAnimation(animations, completion: completion)
        }

        let inheritedDuration = inheritedAnimationDuration

        setAnimationDuration(0.0)
        Transaction.begin()
        AnimationQueue.begin()

        Transaction.animationDuration = 0.0
        Transaction.completionBlock = {
            completion?(true)
        }

        AnimationQueue.enqueue(
            RegularContainer(
                withDelay: max(delay, 0.0),
                duration: duration,
                curve: curve,
                animations: animations
            )
        )

        AnimationQueue.commit()
        Transaction.commit()
        setAnimationDuration(inheritedDuration)
    }

    public static func addKeyframe(withRelativeStartTime frameStartTime: Double, relativeDuration frameDuration: Double, curve: TimingCurve = .cubic(.linear), animations: @escaping AnimationBlock) {
        guard frameDuration > 0.0 && !Transaction.disableActions else { return executeWithoutAnimation(animations) }
        
        AnimationQueue.enqueue(
            KeyframeContainer(
                with: frameStartTime,
                relativeDuration: frameDuration,
                curve: curve,
                animations: animations
            )
        )
    }

    private static func executeWithoutAnimation(_ animations: AnimationBlock, completion: AnimationCompletion? = nil) {
        Transaction.begin()
        Transaction.animationDuration = 0.0
        Transaction.disableActions = true
        animations()
        completion?(true)
        Transaction.commit()
    }
}
