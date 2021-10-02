import Foundation

public class KeyframeTiming: TimingParameters, Overlappable {
    public var curve: TimingCurve
    public var relativeStartTime: Double
    public var relativeDuration: Double
    public var totalDuration: Double
    public var range: Range<Double> {
        return relativeStartTime..<(relativeStartTime + relativeDuration)
    }

    public init(curve: TimingCurve = .systemDefault, relativeStartTime: Double = .zero, relativeDuration: Double = 1.0, totalDuration: Double = .zero) {
        self.curve = curve
        self.relativeStartTime = relativeStartTime
        self.relativeDuration = relativeDuration
        self.totalDuration = totalDuration
    }

    public func overlaps(_ overlappable: KeyframeTiming) -> Bool {
        return range.overlaps(overlappable.range)
    }

    public func progress(at time: Double) -> Progress {
        return curve.progress(at: time)
    }

    public static func == (lhs: KeyframeTiming, rhs: KeyframeTiming) -> Bool {
        return lhs.range == rhs.range && lhs.curve == rhs.curve && lhs.totalDuration == rhs.totalDuration && lhs.relativeDuration == rhs.relativeDuration && lhs.relativeStartTime == rhs.relativeStartTime
    }
}
