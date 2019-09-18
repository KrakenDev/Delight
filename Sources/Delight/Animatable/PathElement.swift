//
//  PathElement.swift
//  Delight
//
//  Created by Hector Matos on 9/14/18.
//

import UIKit

public struct PathElement {
    enum Operation: Int, Comparable {
        case move
        case addLine
        case addQuadCurve
        case addCurve
        case closeSubpath
        case openSubpath

        static func <(lhs: Operation, rhs: Operation) -> Bool {
            return lhs == .closeSubpath || lhs.rawValue < rhs.rawValue && rhs != .closeSubpath
        }
    }

    private(set) var origin: CGPoint
    private(set) var control1: CGPoint
    private(set) var control2: CGPoint
    private(set) var destination: CGPoint
    
    var operation: Operation

    public var bezierCurve: CubicBezierCurve {
        switch operation {
        case .addQuadCurve:
            let control1 = origin.lerp(to: self.control1, with: 2.0/3.0)
            let control2 = destination.lerp(to: self.control1, with: 2.0/3.0)
            return CubicBezierCurve(points: [origin, control1, control2, destination])
        case .move, .addCurve, .openSubpath:
            return CubicBezierCurve(points: [origin, control1, control2, destination])
        case .addLine, .closeSubpath:
            let halfway = origin.lerp(to: destination, with: 0.5)
            let control1 = origin.lerp(to: halfway, with: 2.0/3.0)
            let control2 = destination.lerp(to: halfway, with: 2.0/3.0)
            return CubicBezierCurve(points: [origin, control1, control2, destination])
        }
    }

    init(operation: Operation = .move, origin: CGPoint? = nil, control1: CGPoint? = nil, control2: CGPoint? = nil, destination: CGPoint? = nil) {
        self.operation = operation

        self.origin = origin ?? destination ?? .zero
        self.control1 = control1 ?? origin ?? destination ?? .zero
        self.control2 = control2 ?? destination ?? origin ?? .zero
        self.destination = destination ?? origin ?? .zero

        if operation == .move {
            self.origin = self.destination
            self.control1 = self.destination
            self.control2 = self.destination
        }
    }

    public func add(to path: CGMutablePath) {
        switch operation {
        case .move, .openSubpath:
            path.move(to: origin)
            path.addCurve(to: destination, control1: control1, control2: control2)
        default:
            path.addCurve(to: destination, control1: control1, control2: control2)
        }
    }
}

extension PathElement: Animatable {
    public func lerp(to newValue: PathElement, with progress: Double) -> PathElement {
        guard progress != 1.0 else { return newValue }

        var operation = max(self.operation, newValue.operation)

        switch (self.operation, newValue.operation) {
        case (.move, _) where self.operation != newValue.operation,
             (_, .move) where self.operation != newValue.operation:
            operation = .openSubpath
        default: break
        }

        let oldCurve = bezierCurve
        let newCurve = newValue.bezierCurve
        return PathElement(
            operation: operation,
            origin: CGPoint(point: oldCurve.c0.lerp(to: newCurve.c0, with: progress)),
            control1: CGPoint(point: oldCurve.c1.lerp(to: newCurve.c1, with: progress)),
            control2: CGPoint(point: oldCurve.c2.lerp(to: newCurve.c2, with: progress)),
            destination: CGPoint(point: oldCurve.c3.lerp(to: newCurve.c3, with: progress))
        )
    }
}

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

extension PathElement: Equatable {
    public static func ==(lhs: PathElement, rhs: PathElement) -> Bool {
        return lhs.operation == rhs.operation &&
            lhs.origin == rhs.origin &&
            lhs.control1 == rhs.control1 &&
            lhs.control2 == rhs.control2 &&
            lhs.destination == rhs.destination
    }
}

extension PathElement: CustomStringConvertible {
    public var description: String {
        let operationString: String
        switch operation {
        case .move: operationString = "move"
        case .addLine: operationString = "addLine"
        case .addQuadCurve: operationString = "addQuadCurve"
        case .addCurve: operationString = "addCurve"
        case .closeSubpath: operationString = "closeSubpath"
        case .openSubpath: operationString = "openSubpath"
        }
        return """
            \(operationString)
                from: \(origin)
                to: \(destination)
                control1: \(control1)
                control2: \(control2)
        
        """
    }
}

extension CubicBezierCurve {
    public var pathElement: PathElement {
        return PathElement(
            operation: .addCurve,
            origin: .init(point: c0),
            control1: .init(point: c1),
            control2: .init(point: c2),
            destination: .init(point: c3)
        )
    }
}

