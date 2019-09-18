//
//  TimingParameters.swift
//  Delight
//
//  Created by Hector Matos on 11/17/18.
//

import Foundation

public protocol TimingProgress: CustomStringConvertible {
    associatedtype Timing: BinaryFloatingPoint where Timing.Stride == Timing

    var relativeTime: Timing { get }
    var relativeValue: Timing { get }

    static func start() -> Self
    static func end() -> Self
}

extension TimingProgress {
    public var description: String {
        return "\ttime: \(relativeTime.trim(digitsPastDecimal: 20))\n\tvalue: \(relativeValue.trim(digitsPastDecimal: 20))"
    }
}

public protocol TimingParameters: Equatable {
    associatedtype Progression: TimingProgress
    func progress(at time: Progression.Timing) -> Progression
}

extension TimingParameters {
    public func delay(forRelativeValue relativeValue: Progression.Timing, withDuration duration: Progression.Timing) -> Progression.Timing {
        guard let progression = progressions(from: duration).first(where: {
            relativeValue <= Progression.Timing($0.relativeValue)
        }) else { return 1.0 }

        return Progression.Timing(progression.relativeTime)
    }

    public func progressions(from duration: Progression.Timing) -> [Progression] {
        guard duration > 0.0 else { return [.start(), .end()] }

        let maxFrames = Progression.Timing(View.maxFPS) * duration
        let timeStep = 1.0 / floor(maxFrames)

        return stride(from: 0.0, to: 1.0, by: timeStep).map(progress) + [.end()]
    }
}
