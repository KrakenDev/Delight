import Foundation
import Complex
import Real

extension Int {
    /// `(-1 ± i√3) / 2`
    var rootOfUnity: Complex<Double> {
        self <= .zero ? .one :
            (-1.0 - (.i * √3.0) * -1^Double(self)).halved
    }
}

extension FloatingPoint where Self: Real {
    var complex: Complex<Self> { .init(self) }

    static func ^(lhs: Self, rhs: Self) -> Double {
        pow(Double(lhs), Double(rhs))
    }
    static func ^(lhs: Self, rhs: Int) -> Double {
        pow(Double(lhs), Double(rhs))
    }

    static prefix func √(rhs: Self) -> Complex<Self> {
        √rhs.complex
    }
    static prefix func ∛(rhs: Self) -> Complex<Self> {
        ∛rhs.complex
    }
}

// MARK: - Computed

extension Complex {
    var halved: Complex {
        self / RealType(2.0)
    }
}


// MARK: - Trigonometric

extension Complex {
    var r: RealType { length }
    var theta: RealType { phase }
}


// MARK: - Addition

extension Complex {
    static func +(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            lhs.real + rhs.real,
            lhs.imaginary + rhs.imaginary
        )
    }
    static func +(lhs: Complex, rhs: RealType) -> Complex {
        Complex(
            lhs.real + rhs,
            lhs.imaginary
        )
    }
    static func +(lhs: RealType, rhs: Complex) -> Complex {
        Complex(
            lhs + rhs.real,
            rhs.imaginary
        )
    }
    static func +=(lhs: inout Complex, rhs: RealType) {
        lhs = lhs + rhs.complex
    }
}


// MARK: - Subtraction

extension Complex {
    static func -(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            lhs.real - rhs.real,
            lhs.imaginary - rhs.imaginary
        )
    }
    static func -(lhs: Complex, rhs: RealType) -> Complex {
        Complex(
            lhs.real - rhs,
            lhs.imaginary
        )
    }
    static func -(lhs: RealType, rhs: Complex) -> Complex {
        Complex(
            lhs - rhs.real,
            -rhs.imaginary
        )
    }
}


// MARK: - Multiplication

extension Complex {
    static prefix func -(rhs: Complex) -> Complex {
        rhs * -1.0
    }
    static func *(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
            lhs.imaginary * rhs.real + lhs.real * rhs.imaginary
        )
    }
    static func *(lhs: Complex, rhs: RealType) -> Complex {
        Complex(
            lhs.real * rhs,
            lhs.imaginary * rhs
        )
    }
    static func *(lhs: RealType, rhs: Complex) -> Complex {
        Complex(
            lhs * rhs.real,
            lhs * rhs.imaginary
        )
    }
}


// MARK: - Division

extension Complex {
    static func /(lhs: Complex, rhs: Complex) -> Complex {
        let denominator = rhs.real * rhs.real + rhs.imaginary * rhs.imaginary
        let r = (lhs.real * rhs.real + lhs.imaginary * rhs.imaginary) / denominator
        let i = (lhs.imaginary * rhs.real - lhs.real * rhs.imaginary) / denominator
        return Complex(r, i)
    }
    static func /(lhs: Complex, rhs: RealType) -> Complex {
        Complex(
            lhs.real / rhs,
            lhs.imaginary / rhs
        )
    }
    static func /(lhs: RealType, rhs: Complex) -> Complex {
        Complex(lhs, .zero) / rhs
    }
}


// MARK: - Exponentiation

extension Complex {
    static prefix func √(rhs: Complex) -> Complex {
        rhs^(1.0/2.0)
    }
    static prefix func ∛(rhs: Complex) -> Complex {
        rhs^(1.0/3.0)
    }

    static func ^(lhs: Complex, rhs: RealType) -> Complex {
        lhs^rhs.complex
    }
    static func ^(lhs: Complex, rhs: Complex) -> Complex {
        let r = pow(lhs.r, rhs.real)
            * exp(-rhs.imaginary * lhs.theta)
        let theta = rhs.real * lhs.theta
            + rhs.imaginary * log(lhs.r)

        // cos and sin operations aren't exact due to issues with floating point precision since computers can't truly represent `.pi`. We can't use `.pi`
        return Complex(
            r * cos(theta).removedSlop,
            r * sin(theta).removedSlop
        )
    }
}


// MARK: - Math

precedencegroup PowerPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: left
    assignment: false
}

prefix operator √
prefix operator ∛
infix operator ^: PowerPrecedence
