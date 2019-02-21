import Foundation
import CoreGraphics
import Delight

enum Axis {
    case x
    case y
}

protocol Vector {
    associatedtype FloatType: BinaryFloatingPoint & Comparable
    var x: FloatType { get set }
    var y: FloatType { get set }

    static func increasingOrder(forAxis axis: Axis) -> (Self, Self) -> Bool

    init()
    init(x: FloatType, y: FloatType)
}

extension Vector {
    init(x: FloatType, y: FloatType) {
        self = Self()

        self.x = x
        self.y = y
    }

    init<T: Vector>(vector: T) where T.FloatType == FloatType {
        self = Self()

        x = vector.x
        y = vector.y
    }

    func value(for axis: Axis) -> FloatType {
        return axis == .x ? x : y
    }

    static func increasingOrder(forAxis axis: Axis) -> (Self, Self) -> Bool {
        return { return $0.value(for: axis) < $1.value(for: axis) }
    }
}

extension ControlPoint: Vector {
    var cgPoint: CGPoint { return CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}

extension CGPoint: Vector {
    var controlPoint: ControlPoint { return ControlPoint(x: x, y: y) }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs + CGPoint(x: rhs, y: rhs)
    }

    static func +(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return rhs + lhs
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + -rhs
    }

    static func -(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs + -rhs
    }

    static func -(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return lhs + -rhs
    }

    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs * CGPoint(x: rhs, y: rhs)
    }

    static func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return rhs * lhs
    }

    static func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs / CGPoint(x: rhs, y: rhs)
    }

    static func /(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs / rhs.x, y: lhs / rhs.y)
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    static prefix func -(rhs: CGPoint) -> CGPoint {
        return rhs * -1.0
    }

    func slopeTo(_ other: CGPoint) -> CGFloat {
        guard other.x != x else { return 0 }
        return (other.y - y) / (other.x - x)
    }

    func distanceTo(_ other: CGPoint) -> CGFloat {
        let diff = other - self
        return sqrt(pow(diff.x, 2) + pow(diff.y, 2))
    }
}

func pow<T: BinaryFloatingPoint>(_ value: T, _ power: T) -> T {
    if value is Double {
        return pow(value as! Double, power as! Double) as! T
    } else if value is Float {
        return pow(value as! Float, power as! Float) as! T
    } else if value is CGFloat {
        return pow(value as! CGFloat, power as! CGFloat) as! T
    } else {
        return value
    }
}

