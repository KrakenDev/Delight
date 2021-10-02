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
    func progress(at time: Double) -> Progress
}

extension TimingParameters {
    public func delay(forRelativeValue relativeValue: Double, withDuration duration: Double) -> Double {
        guard let progression = progressions(from: duration).first(where: {
            relativeValue <= $0.relativeValue
        }) else { return 1.0 }

        return progression.relativeTime
    }

    public func progressions(from duration: Double) -> [Progress] {
        guard duration > 0.0 else { return [.start(), .end()] }

        let maxFrames = Double(View.maxFPS) * duration
        let timeStep = 1.0 / floor(maxFrames)

        return stride(from: 0.0, to: 1.0, by: timeStep)
            .map(progress) + [.end()]
    }
}
