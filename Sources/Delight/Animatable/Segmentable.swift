import Foundation
import QuartzCore

public protocol Segmentable {
    associatedtype Segment: Segmentable
    func segmented(by amount: Int) -> [Segment]
}


// MARK: - Bezier Curve

extension CubicBezierCurve: Segmentable {
    public func segmented(by amount: Int) -> [CubicBezierCurve] {
        var segments: [CubicBezierCurve] = []

        var curve = self

        for segment in (1...amount).reversed() {
            let t = 1.0 / Double(segment)

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


// MARK: - Path

extension Path: Segmentable {
    public func segmented(by amount: Int) -> [PathElement] {
        guard amount != segments.count && segmentedCache[amount] == nil else { return segmentedCache[amount] ?? segments }

        var addExtraPart = false
        var remainder = (amount - 1) % (segments.count - 1)
        let baseAmount = (amount - 1) / (segments.count - 1)

        guard baseAmount > 1 || remainder > 0 else { return segments }

        var newSegments: [PathElement] = [segments.first ?? .init()]

        for segment in segments.dropFirst() {
            addExtraPart = remainder > 0

            let segmentAmount = baseAmount + (addExtraPart ? 1 : 0)
            let subSegments = segment.segmented(by: segmentAmount)
            newSegments.append(contentsOf: subSegments)

            remainder -= subSegments.count == segmentAmount ? 1 : subSegments.count - segmentAmount
        }

        updateBoundingBox()
        segmentedCache[amount] = newSegments
        return newSegments
    }
}


// MARK: - PathElement

extension PathElement: Segmentable {
    public func segmented(by amount: Int) -> [PathElement] {
        var segments: [PathElement] = []

        switch operation {
        case .move:
            segments.append(self)
        case .openSubpath:
            segments.append(PathElement(operation: .move, destination: destination))

            var element = self
            element.operation = .addCurve
            segments.append(contentsOf: element.segmented(by: amount - 1))
        case .addLine, .closeSubpath, .addQuadCurve, .addCurve:
            segments.append(contentsOf: bezierCurve.segmented(by: amount).map(\.pathElement))
        }

        return segments
    }
}


// MARK: - CGColor

extension CGColor: Segmentable {
    public func segmented(by amount: Int) -> [CGColor] {
        stride(from: 0.0, to: 1.0, by: 1.0/Double(amount)).map {
            lerp(to: .black, with: $0)
        }
    }
}


// MARK: - CAShapeLayer

extension CAShapeLayer: Segmentable {
    public func segmented(by amount: Int) -> [CAShapeLayer] {
        guard let segments = path?.path.segments else { return [self] }

        var layers: [CAShapeLayer] = []
        for (segment, color) in zip(segments, CGColor.white.segmented(by: segments.count)) {
            let debugCurveLayer = CAShapeLayer()
            debugCurveLayer.lineWidth = 3.0
            debugCurveLayer.strokeColor = color
            debugCurveLayer.fillColor = CGColor.clear

            let mutablePath = CGMutablePath()
            mutablePath.move(to: segment.bezierCurve.c0.cg)
            segment.add(to: mutablePath)

            debugCurveLayer.path = mutablePath
            layers.append(removingPossibleDuplicate: debugCurveLayer)
        }

        return layers
    }
}
