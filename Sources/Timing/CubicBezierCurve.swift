//
//  CubicBezierCurve.swift
//  Delight-iOS
//
//  Created by Hector Matos on 9/13/18.
//

import Foundation
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
    private let circleApproxConstant: CGFloat = 0.551915024494

    public var controlPoints: [ControlPoint] = [] {
        didSet {
            c0 = controlPoints[0]
            c1 = controlPoints[1]
            c2 = controlPoints[2]
            c3 = controlPoints[3]
        }
    }

    public static let zero = CubicBezierCurve(.zero, .zero)

    var CCurve: CCubicBezierCurve {
        return .init(c0: c0.CPoint, c1: c1.CPoint, c2: c2.CPoint, c3: c3.CPoint)
    }

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

    init(cCurve: CCubicBezierCurve) {
        self.init(.init(cPoint: cCurve.c1), .init(cPoint: cCurve.c2))
    }

    init(functionName: CAMediaTimingFunctionName) {
        let timingFunction = CAMediaTimingFunction(name: functionName)
        var c1: [Float] = [0.0, 0.0]
        var c2: [Float] = [0.0, 0.0]
        timingFunction.getControlPoint(at: 1, values: &c1)
        timingFunction.getControlPoint(at: 2, values: &c2)

        self.init(.init(timingFunctionPoint: c1), .init(timingFunctionPoint: c2))
    }

    public func pointOnCurve(for currentTimeStep: Double) -> Progress<Double> {
        let curvePoint = CurvePointOnBezierCurveAtT(CCurve, currentTimeStep)
        return Progress(cCurvePoint: curvePoint)
    }
}

extension CubicBezierCurve: TimingParameters {
    public func progress(at time: Double) -> Progress<Double> {
        return Progress(cCurvePoint: CurvePointIntersectingCurveAtT(CCurve, Double(time)))
    }

    public static func ==(lhs: CubicBezierCurve, rhs: CubicBezierCurve) -> Bool {
        return lhs.controlPoints == rhs.controlPoints
    }
}

extension CubicBezierCurve: Segmentable {
    func segmented(by amount: Int) -> [CubicBezierCurve] {
        var segments: [CubicBezierCurve] = []

        var curve = self

        for segment in (1...amount).reversed() {
            let t = 1.0 / CGFloat(segment)

            let d0 = curve.c0.lerp(to: curve.c1, with: t)
            let d1 = curve.c1.lerp(to: curve.c2, with: t)
            let d2 = curve.c2.lerp(to: curve.c3, with: t)

            let e0 = d0.lerp(to: d1, with: t)
            let e1 = d1.lerp(to: d2, with: t)

            let f0 = e0.lerp(to: e1, with: t)

            let leftHalf = [curve.c0, d0, e0, f0]
            let rightHalf = [f0, e1, d2, curve.c3]

            segments.append(CubicBezierCurve(points: leftHalf))
            curve = CubicBezierCurve(points: rightHalf)
        }

        return segments
    }
}

extension Progress where Timing == Double {
    public init(cCurvePoint: CCurvePoint) {
        relativeTime = cCurvePoint.relativeTime
        relativeValue = cCurvePoint.relativeValue
    }
}
