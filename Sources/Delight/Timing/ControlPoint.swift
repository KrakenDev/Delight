import CoreGraphics

typealias TimingFunctionPoint = [Float]

public struct ControlPoint {
    public var x: Double = .zero
    public var y: Double = .zero

    public static let zero = ControlPoint(x: 0.0, y: 0.0)
    public static let unit = ControlPoint(x: 1.0, y: 1.0)

    public init() {
        self.x = .zero
        self.y = .zero
    }

    public init(x: Double, y: Double) {
        self.x = .init(x)
        self.y = .init(y)
    }

    init(cgPoint: CGPoint) {
        self.x = .init(cgPoint.x)
        self.y = .init(cgPoint.y)
    }
    
    init(timingFunctionPoint point: TimingFunctionPoint) {
        self.init(x: Double(point[0]), y: Double(point[1]))
    }
}

extension ControlPoint: Equatable {
    public static func ==(lhs: ControlPoint, rhs: ControlPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension ControlPoint: CustomStringConvertible {
    public var description: String {
        return "{ x: \(x), y: \(y) }"
    }
}

public extension CGPoint {
    init(point: ControlPoint) {
        self.init(x: point.x, y: point.y)
    }
}
