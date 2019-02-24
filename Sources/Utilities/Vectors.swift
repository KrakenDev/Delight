import Foundation
import CoreGraphics

public enum Axis {
    case x
    case y
}

public protocol Vector {
    associatedtype FloatType: BinaryFloatingPoint & Comparable
    var x: FloatType { get set }
    var y: FloatType { get set }

    static func increasingOrder(forAxis axis: Axis) -> (Self, Self) -> Bool

    init()
    init(x: FloatType, y: FloatType)
    
    func distance(to other: Self) -> FloatType
    func slope(to other: Self) -> FloatType
}

extension Vector {
    public init(x: FloatType, y: FloatType) {
        self = Self()

        self.x = x
        self.y = y
    }

    public init<T: Vector>(vector: T) where T.FloatType == FloatType {
        self = Self()

        x = vector.x
        y = vector.y
    }

    public func value(for axis: Axis) -> FloatType {
        return axis == .x ? x : y
    }
    
    public func distance(to other: Self) -> FloatType {
        let xDelta = pow(other.x - x, 2)
        let yDelta = pow(other.y - y, 2)
        return sqrt(xDelta + yDelta)
    }

    public func slope(to other: Self) -> FloatType {
        guard other.x != x else { return 0 }
        return (other.y - y) / (other.x - x)
    }

    public static func increasingOrder(forAxis axis: Axis) -> (Self, Self) -> Bool {
        return { return $0.value(for: axis) < $1.value(for: axis) }
    }
}

extension ControlPoint: Vector {
    public var cgPoint: CGPoint { return CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}

extension CGPoint: Vector {
    public var controlPoint: ControlPoint { return ControlPoint(x: x, y: y) }

    public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs + CGPoint(x: rhs, y: rhs)
    }

    public static func +(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return rhs + lhs
    }

    public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + -rhs
    }

    public static func -(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs + -rhs
    }

    public static func -(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return lhs + -rhs
    }

    public static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    public static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs * CGPoint(x: rhs, y: rhs)
    }

    public static func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return rhs * lhs
    }

    public static func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    public static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs / CGPoint(x: rhs, y: rhs)
    }

    public static func /(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs / rhs.x, y: lhs / rhs.y)
    }

    public static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }

    public static prefix func -(rhs: CGPoint) -> CGPoint {
        return rhs * -1.0
    }
}

public func pow<T: BinaryFloatingPoint>(_ value: T, _ power: T) -> T {
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

