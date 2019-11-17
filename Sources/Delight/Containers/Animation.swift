//
//  Animation.swift
//  Delight
//
//  Created by Hector Matos on 9/28/18.
//

public typealias VoidBlock = () -> Void
public typealias AnimationBlock = VoidBlock
public typealias AnimationCompletion = (Bool) -> Void
public typealias AnimationExecution<T: Keyframe> = ([T]) -> Void

public protocol Animation: class {
    associatedtype Value: Animatable

    var duration: Value.Progression { get set }
    var keyTimes: [Value.Progression] { get set }
    var values: [Value] { get set }
}

public class AnyAnimation<T: Animatable> {
    private let getDuration: () -> TimeInterval
    private let setDuration: (TimeInterval) -> Void

    private let getKeyTimes: () -> [Double]
    private let setKeyTimes: ([Double]) -> Void

    private let getValues: () -> [Any]
    private let setValues: ([Any]) -> Void

    public init<T: Animation>(_ animation: T) where T.Value.Progression == Double {
        getDuration = { animation.duration }
        setDuration = { animation.duration = $0 }

        getKeyTimes = { animation.keyTimes }
        setKeyTimes = { animation.keyTimes = $0 }

        getValues = { animation.values }
        setValues = {
            guard let values = $0 as? [T.Value] else { return }
            animation.values = values
        }
    }
}

struct DeferredAnimation {
    let keyframes: [Any]
    let cachedCommits: VoidBlock
    let cachedAnimations: VoidBlock
}
