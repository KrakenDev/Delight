import Foundation
import Numerics

extension Int {
    var complex: Complex<Double> {
        Complex(Double(self))
    }
}

extension Double {
    var complex: Complex<Double> {
        Complex(self)
    }
}

// MARK: - Math Operators

precedencegroup ExponentPrecendence {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ^^: ExponentPrecendence
public func ^^ <N: BinaryInteger>(base: N, power: N) -> N {
    return N(pow(Double(base), Double(power)))
}

public func ^^ <N: BinaryFloatingPoint>(base: N, power: N) -> N {
    return N(pow(Double(base), Double(power)))
}

prefix operator √
prefix func √ <T: BinaryInteger>(_ value: T) -> Complex<Double> {
    return √Double(value)
}
prefix func √ <T: Real>(_ value: T) -> Complex<T> {
    return √Complex(value)
}
prefix func √ <T: Real>(_ value: Complex<T>) -> Complex<T> {
    return .sqrt(value)
}

prefix operator ∛
prefix func ∛ <T: BinaryInteger>(_ value: T) -> Complex<Double> {
    return ∛Double(value)
}
prefix func ∛ <T: Real>(_ value: T) -> Complex<T> {
    return ∛Complex(value)
}
prefix func ∛ <T: Real>(_ value: Complex<T>) -> Complex<T> {
    return .root(value, 3)
}

infix operator ± : AdditionPrecedence
func ± <T: Numeric>(lhs: T, rhs: T) -> (T, T) {
    return (lhs + rhs, lhs - rhs)
}

prefix operator ±
prefix func ± <T: Numeric>(_ value: T) -> (T, T) {
    return 0 ± value
}
