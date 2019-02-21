//
//  LayerAnimation.swift
//  Delight
//
//  Created by Hector Matos on 10/3/18.
//

class LayerAnimation<T: Animatable>: Animation {
    var values: [T]
    var keyTimes: [T.Progression]
    var duration: T.Progression

    required init<U: Keyframe>(from keyframe: U) where U.AnimationInstance.Value.Value == T {
        let timing = keyframe.timing
        duration = timing.relativeDuration * timing.totalDuration

        let (start, end) = (keyframe.valueProvider.start, keyframe.valueProvider.end)
        let timingProgressions = timing.progressions(from: duration)

        keyTimes = timingProgressions.map { timing.relativeStartTime + timing.relativeDuration * T.Progression($0.relativeTime) }
        values = timingProgressions.map { start.lerp(to: end, with: T.Progression($0.relativeValue)) }
    }
}
