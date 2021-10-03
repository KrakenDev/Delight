import Foundation

extension Int {
    var reciprocal: Double {
        Double(self).reciprocal ?? 1.0/Double(self)
    }
}

// MARK: - Math Operators

precedencegroup ExponentPrecendence {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ^^: ExponentPrecendence
prefix operator √
prefix operator ∛

extension BinaryInteger {
    static func ^^ (lhs: Self, rhs: Int) -> Double {
        pow(Double(lhs), Double(rhs))
    }

    prefix static func √ (_ value: Self) -> Double {
        sqrt(Double(value))
    }

    prefix static func ∛ (_ value: Self) -> Double {
        cbrt(Double(value))
    }
}

extension BinaryFloatingPoint {
    static func ^^ (lhs: Self, rhs: Int) -> Double {
        pow(Double(lhs), Double(rhs))
    }

    prefix static func √ (_ value: Self) -> Double {
        sqrt(Double(value))
    }

    prefix static func ∛ (_ value: Self) -> Double {
        cbrt(Double(value))
    }
}
