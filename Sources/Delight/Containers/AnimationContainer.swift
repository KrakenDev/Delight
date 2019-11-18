//
//  AnimationContainer.swift
//  Delight
//
//  Created by Hector Matos on 10/3/18.
//

/**
 * Representation of animation blocks that can contain property updates. Since animations are
 * inherently keyframe data sources (they are aware of timings and such), this protocol inherits
 * from KeyframeDataSource.
 */
public protocol AnimationContainer {
    var timing: KeyframeTiming { get }
    var isExecuting: Bool { get }

    /**
     * This adds a keyframe to the list of keyframes to run when commitAnimations()
     * is called. The default implementation converts the keyframe into an object that implements
     * the Animation protocol.
     */
    func addAnimation<T: Keyframe>(for keyframe: T?, using animationFromRelatedKeyframes: @escaping AnimationExecution<T>)

    /**
     * Animations are nestable so this provides a plug for the receiver to execute the
     * animations block and inherit timing curves from the container passed in.
     */
    func nest(inside container: AnimationContainer?)

    func executeAnimations()
}

extension AnimationContainer {
    func executeAnimations() {}
}
