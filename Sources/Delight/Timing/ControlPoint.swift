//
//  ControlPoint.swift
//  Delight-iOS
//
//  Created by Hector Matos on 9/13/18.
//

import UIKit

typealias TimingFunctionPoint = [Float]

public struct ControlPoint {
    public var x: Double
    public var y: Double

    public static let zero = ControlPoint(x: 0.0, y: 0.0)
    public static let unit = ControlPoint(x: 1.0, y: 1.0)

    public init() {
        self.x = 0.0
        self.y = 0.0
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

extension CGPoint {
    init(point: ControlPoint) {
        self.init(x: point.x, y: point.y)
    }
}
