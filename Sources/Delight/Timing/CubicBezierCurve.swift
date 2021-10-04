import CoreGraphics
import QuartzCore

public struct CubicBezierCurve {
    public var c0: ControlPoint
    public var c1: ControlPoint
    public var c2: ControlPoint
    public var c3: ControlPoint

    public var circleApproximation: CubicBezierCurve {
        let shouldSwitch = c0.x > c3.x && c0.y < c3.y || c0.x < c3.x && c0.y > c3.y

        let newC0 = shouldSwitch ? c0 : c3
        let newC3 = shouldSwitch ? c3 : newC0

        let x = newC0.x.lerp(to: newC3.x, with: circleApproxConstant)
        let y = newC3.y.lerp(to: newC0.y, with: circleApproxConstant)

        let newC1: ControlPoint = .init(x: x, y: newC3.y)
        let newC2: ControlPoint = .init(x: newC0.x, y: y)

        return .init(points: [newC0, newC1, newC2, newC3])
    }

    // http://spencermortensen.com/articles/bezier-circle/
    private let circleApproxConstant: Double = 0.551915024494

    public var controlPoints: [ControlPoint] = [] {
        didSet {
            c0 = controlPoints[0]
            c1 = controlPoints[1]
            c2 = controlPoints[2]
            c3 = controlPoints[3]
        }
    }

    public var boundingBox: CGRect {
        CGRect(
            origin: CGPoint(
                x: controlPoints.map(\.x).min(by: <) ?? .zero,
                y: controlPoints.map(\.y).min(by: <) ?? .zero
            ),
            size: CGSize(
                width: controlPoints.map(\.x).max(by: <) ?? .zero,
                height: controlPoints.map(\.y).max(by: <) ?? .zero
            )
        )
    }

    public static let zero = CubicBezierCurve(.zero, .zero)

    public init(_ point1: ControlPoint, _ point2: ControlPoint) {
        c0 = .zero; c1 = point1; c2 = point2; c3 = .unit
        controlPoints = [c0, c1, c2, c3]
    }

    public init(points: [ControlPoint]) {
        c0 = points[0]; c1 = points[1]; c2 = points[2]; c3 = points[3]
        controlPoints = [c0, c1, c2, c3]
    }

    public init(points: [CGPoint]) {
        c0 = .init(cgPoint: points[0])
        c1 = .init(cgPoint: points[1])
        c2 = .init(cgPoint: points[2])
        c3 = .init(cgPoint: points[3])

        controlPoints = [c0, c1, c2, c3]
    }

    init(functionName: CAMediaTimingFunctionName) {
        let timingFunction = CAMediaTimingFunction(name: functionName)
        var c1: [Float] = [0.0, 0.0]
        var c2: [Float] = [0.0, 0.0]
        timingFunction.getControlPoint(at: 1, values: &c1)
        timingFunction.getControlPoint(at: 2, values: &c2)

        self.init(.init(timingFunctionPoint: c1), .init(timingFunctionPoint: c2))
    }
}

extension CubicBezierCurve: TimingParameters {
    public static func ==(lhs: CubicBezierCurve, rhs: CubicBezierCurve) -> Bool {
        return lhs.controlPoints == rhs.controlPoints
    }
}
