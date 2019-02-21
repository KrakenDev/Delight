//
//  ControlPoint.swift
//  Delight-iOS
//
//  Created by Hector Matos on 9/13/18.
//

import CoreGraphics

typealias TimingFunctionPoint = [Float]

public struct ControlPoint {
    public var x: CGFloat
    public var y: CGFloat

    public static let zero = ControlPoint(x: 0.0, y: 0.0)
    public static let unit = ControlPoint(x: 1.0, y: 1.0)

    var CPoint: CControlPoint {
        return .init(x: Double(x), y: Double(y))
    }

    public init() {
        self.x = 0.0
        self.y = 0.0
    }

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    init(cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
    
    init(cPoint: CControlPoint) {
        self.init(x: CGFloat(cPoint.x), y: CGFloat(cPoint.y))
    }

    init(timingFunctionPoint point: TimingFunctionPoint) {
        self.init(x: CGFloat(point[0]), y: CGFloat(point[1]))
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

extension CGPoint {
    init(point: ControlPoint) {
        self.init(x: point.x, y: point.y)
    }
}
