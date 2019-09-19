//
//  TimingParameters.swift
//  Delight
//
//  Created by Hector Matos on 11/17/18.
//

import Foundation

public protocol TimingProgress: CustomStringConvertible {
    associatedtype Timing: BinaryFloatingPoint

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
    associatedtype Progression: BinaryFloatingPoint
    func progress(at time: Progression) -> Progress<Progression>
}

extension TimingParameters {
    public func delay(forRelativeValue relativeValue: Progression, withDuration duration: Progression) -> Progression {
        guard let progression = progressions(from: duration).first(where: {
            relativeValue <= Progression($0.relativeValue)
        }) else { return 1.0 }

        return progression.relativeTime
    }

    public func progressions(from duration: Progression) -> [Progress<Progression>] {
        guard duration > 0.0 else { return [.start(), .end()] }

        let maxFrames = Progression(View.maxFPS) * duration
        let timeStep = Double(1.0 / floor(maxFrames))

        return stride(from: 0.0, to: 1.0, by: timeStep)
            .map {
                return progress(at: Progression($0))
            }
            + [.end()]
    }
}
