import Foundation

public struct Progress: TimingProgress {
    public let relativeTime: Double
    public let relativeValue: Double

    public static func start() -> Progress {
        return Progress(relativeTime: 0.0, relativeValue: 0.0)
    }
    public static func end() -> Progress {
        return Progress(relativeTime: 1.0, relativeValue: 1.0)
    }
}
