import Foundation

public typealias VoidBlock = () -> Void
public typealias AnimationBlock = VoidBlock
public typealias AnimationCompletion = (Bool) -> Void
public typealias AnimationExecution<T: Keyframe> = ([T]) -> Void

public protocol Animation: AnyObject {
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

    public init<U: Animation>(_ animation:U) where U.Value == T {
        getDuration = { Double(animation.duration) }
        setDuration = { animation.duration = T.Progression($0) }

        getKeyTimes = { animation.keyTimes.map(Double.init) }
        setKeyTimes = { animation.keyTimes = $0.map(T.Progression.init) }

        getValues = { animation.values }
        setValues = {
            guard let values = $0 as? [T] else { return }
            animation.values = values
        }
    }
}

struct DeferredAnimation {
    let keyframes: [Any]
    let cachedCommits: VoidBlock
    let cachedAnimations: VoidBlock
}
