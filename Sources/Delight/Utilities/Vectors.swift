import Foundation
import CoreGraphics

// MARK: - Vector

public protocol Vector {
    associatedtype FloatType: BinaryFloatingPoint & Comparable

    var x: FloatType { get set }
    var y: FloatType { get set }

    init()
    init(x: FloatType, y: FloatType)

    func distance(to other: Self) -> FloatType
    func slope(to other: Self) -> FloatType

    // MARK: - Addition
    static func +(lhs: FloatType, rhs: Self) -> Self
    static func +(lhs: Self, rhs: FloatType) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
    static func +=(lhs: inout Self, rhs: FloatType)
    static func +=(lhs: inout Self, rhs: Self)

    // MARK: - Subtraction
    static func -(lhs: FloatType, rhs: Self) -> Self
    static func -(lhs: Self, rhs: FloatType) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func -=(lhs: inout Self, rhs: FloatType)
    static func -=(lhs: inout Self, rhs: Self)
    static prefix func -(rhs: Self) -> Self

    // MARK: - Multiplication
    static func *(lhs: FloatType, rhs: Self) -> Self
    static func *(lhs: Self, rhs: FloatType) -> Self
    static func *(lhs: Self, rhs: Self) -> Self

    // MARK: - Division
    static func /(lhs: FloatType, rhs: Self) -> Self
    static func /(lhs: Self, rhs: FloatType) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}


// MARK: - CGPoint

extension CGPoint: Vector {}


// MARK: - Default Conformance

public extension Vector {
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

    func distance(to: Self) -> FloatType {
        .init(hypot(
            Double(to.x - x),
            Double(to.y - y))
        )
    }

    func slope(to other: Self) -> FloatType {
        guard other.x != x else { return 0 }
        return (other.y - y) / (other.x - x)
    }
}


// MARK: BinaryFloatingPoint

extension BinaryFloatingPoint {
    func vector<T: Vector>() -> T where T.FloatType == Self {
        .init(x: self, y: self)
    }
}


// MARK: - Vector Operations

public extension Vector {

    // MARK: - Addition

    static func +(lhs: FloatType, rhs: Self) -> Self {
        lhs.vector() + rhs
    }
    static func +(lhs: Self, rhs: FloatType) -> Self {
        lhs + rhs.vector()
    }
    static func +(lhs: Self, rhs: Self) -> Self {
        .init(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    static func +=(lhs: inout Self, rhs: FloatType) {
        lhs += rhs.vector()
    }
    static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }


    // MARK: - Subtraction

    static func -(lhs: FloatType, rhs: Self) -> Self {
        lhs.vector() - rhs
    }
    static func -(lhs: Self, rhs: FloatType) -> Self {
        lhs - rhs.vector()
    }
    static func -(lhs: Self, rhs: Self) -> Self {
        lhs + -rhs
    }
    static func -=(lhs: inout Self, rhs: FloatType) {
        lhs -= rhs.vector()
    }
    static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    static prefix func -(rhs: Self) -> Self {
        rhs * -1.0
    }


    // MARK: - Multiplication

    static func *(lhs: FloatType, rhs: Self) -> Self {
        lhs.vector() * rhs
    }
    static func *(lhs: Self, rhs: FloatType) -> Self {
        lhs * rhs.vector()
    }
    static func *(lhs: Self, rhs: Self) -> Self {
        .init(
            x: lhs.x * rhs.x,
            y: lhs.y * rhs.y
        )
    }


    // MARK: - Division

    static func /(lhs: FloatType, rhs: Self) -> Self {
        lhs.vector() / rhs
    }
    static func /(lhs: Self, rhs: FloatType) -> Self {
        lhs / rhs.vector()
    }
    static func /(lhs: Self, rhs: Self) -> Self {
        .init(
            x: lhs.x / rhs.x,
            y: lhs.y / rhs.y
        )
    }
}
