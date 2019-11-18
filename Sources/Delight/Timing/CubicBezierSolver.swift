//
//  CubicBezierSolver.swift
//  Delight
//
//  Created by Hector Matos on 9/18/19.
//

import UIKit
import Complex

extension CubicBezierCurve {
    enum Axes {
        case verticalAxis
        case horizontalAxis
    }
    struct Coefficients {
        let a: Double
        let b: Double
        let c: Double
        let d: Double
        
        var all: [Double] {
            return [a, b, c, d]
        }
    }
}

extension Complex {
    public static func cbrt(_ value: Self) -> Self {
        return pow(value, Self(1/3))
    }
}

extension ControlPoint {
    func translatedBy(dx: Double, dy: Double = 0.0) -> ControlPoint {
        return ControlPoint(x: x + dx, y: y + dy)
    }
    // In degrees
    func rotatedAroundOrigin(by angle: Double = 90.0) -> ControlPoint {
        return ControlPoint(
            x: x * cos(angle.radians) - y * sin(angle.radians),
            y: x * sin(angle.radians) + y * cos(angle.radians)
        )
    }
}


// MARK: - Bezier Solvers

/**
 Bezier curves are derived from a t value, which represents time normalized to a
 percent (0.0->1.0)
 
 Given a number of control points, we can use polynomials of t. The order of the
 polynomial is the count of our control points - 1.
 
 The simplest curve is a straight line. We typically represent lines by how long
 they are. Since t is always between 0 and 1, then how do we represent the length
 of this line using our t?
 
 Well, if t is a portion of the line, and 1 - t is the rest of the line, then we
 can represent that like this:
 
 line = t + (1 - t)
 
 Since our control points are 0 and 1 (a & b), how do they factor into the equation?
 Well if we know that functions are representations of f(x) where x == 0, then let's
 try to plug a and b into our function when t == 0:
 
 0 = a*t + b(1-t)
 0 = 0*0 + 1(1-0) -> 1 (NOPE)
 
 0 = b*t + a(1-t)
 0 = 1*0 + 0(1-0) -> 0 (YUP)
 
 This makes our complete representation of a line to be
 f(t) = a(1-t) + bt
 
 When we increase the number of control points, then that means we increase the order of
 this function by how many control points we added. Since control points change between
 different curve orders, then we drop them, increase the order of the remaining function,
 and prepend them after.
 
 [For the sake of simplicity, u=(1-t)]:
 
 f(t) = (2 control points) = (u + t)¹ = au¹ + bt
 f(t) = (3 control points) = (u + t)² = au² + 2but + ct²
 f(t) = (4 control points) = (u + t)³ = au³ + 3btu² + 3ct²u + dt³
 
 The functions below are just derivations of the above formulas. So let's get started!
 */

/******************************THE Cubic Bezier Solver******************************/
extension CubicBezierCurve {
    /**
     The formula for a cubic function's roots is below. The code you find
     has been translated from Cardano's solution to the cubic equation that
     I found here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#7_u3
     */
    var root: Double {
        /**
         To begin solving for 0 in a cubic equation, we need divide our coefficients by a.
         This gives us less coefficients to work with without changing the value of the roots.
         */
        let coefficients = self.coefficients(for: .verticalAxis)
        let a = coefficients.b / coefficients.a
        let b = coefficients.c / coefficients.a
        let c = coefficients.d / coefficients.a
        
        /**
         There are optimized ways of finding the root of a cubic
         function by determining what's called the "discriminant" of
         the polynomial.
         
         Discriminants(Δ) tell you how many roots there are when solving
         a polynomial. Take for instance, the quadratic formula. To
         solve for 0, you eventually need to take the square root of
         something since you need to reduce x² to x. For quadratic
         equations, (b² - 4ac) is what lies within a square root.
         So that makes b² - 4ac the "discriminant". This is because
         you can have two solutions to a square root. Knowing that,
         we can actually use the "discriminant"(Δ) to determine how many
         many roots/solutions to the equation are real numbers!
         
         Discriminants are denoted with Δ. Check it out:
         
         Δ > 0: 2 real roots
         Δ = 0: 1 real root, 1 imaginary
         Δ < 0: 2 imaginary roots (the sqrt of -1 is i)
         
         In each case of the discriminant, the solutions for the roots are translated from
         here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#The_Value_of_the_Discriminant_%CE%94
         */
        
        // The value of the first coefficient after reducing to the depressed cubic
        let simpleRoot = -a/3
        
        let p = (3*b - a.squared) / 9
        let q = (2*a.cubed - 9*a*b + 27*c) / 54
        let discriminant = Complex(p.cubed + q.squared) // Δ
        var root = Complex(0.0)

        (0...2).forEach { i in
            let i = Double(i)
            let rootOfUnity = i.rootOfUnity
            var possibleRoot: Complex<Double>

            if 3*p == 0 || 2*q == 0 {
                let pIsZeroRoot: Complex<Double> = (-2*q).cubeRoot * rootOfUnity
                let qIsZeroRoot = -1^i * (-3*p).squareRoot * min(i, 1)
                possibleRoot = (p == 0) ? pIsZeroRoot : Complex(qIsZeroRoot)
            } else if discriminant == Complex(0.0) {
                // Δ = 0: 3 real roots, but two of them are equal
                let power: Double = (i == 0) ? 1 : 2
                possibleRoot = Complex(2^(2-power) * (q*(-1^power)).cubeRoot)
            } else if discriminant.real > 0 {
                // Δ > 0: 1 real root, 2 imaginary roots
                let m = Complex.sqrt(discriminant) - q
                let u = Complex.cbrt(m) * rootOfUnity
                let n = Complex.sqrt(discriminant) + q
                let v = Complex.cbrt(n) * rootOfUnity.conj
                possibleRoot = u - v
            } else {
                // Δ < 0: 3 real unique roots
                let r = abs(p).cubed.squareRoot
                let phi = acos(-q/r) + i.doubled * .pi // Φ
                possibleRoot = Complex(r.cubeRoot.doubled * cos(phi/3))
            }
            
            possibleRoot += simpleRoot
            
            if possibleRoot.imag == 0 && possibleRoot.real.isUniform {
                root = possibleRoot
            }
        }
        
        return root.real
    }

    /**
     We can generate our coefficients by expanding our formulas and simplifying
     them in terms of t. BTW, coefficients are the thingies you multiply tⁿ by.
     
     Let's see what that looks like:
     -> f(t) = au³ + 3btu² + 3ct²u + dt³
     -> f(t) = a(1-t)³ + 3bt(1-t)² + 3ct²(1-t) + dt³
     -> f(t) = a(1-2t+t²)(1-t) + 3bt(1-2t+t²) + c(3t²-3t³) + dt³
     -> f(t) = a(1-3t+3t²-t³) + b(3t-6t²+3t³) + c(3t²-3t³) + dt³
     -> f(t) = (a-3at+3at²-at³) + (3bt-6bt²+3bt³) + (3ct²-3ct³) + dt³
     -> f(t) = a + -3at + 3at² + -at³ + 3bt + -6bt² + 3bt³ + 3ct² + -3ct³ + dt³
     -> f(t) = (dt³ - 3ct³ + 3bt³ - at³) + (3ct² - 6bt² + 3at²) - (3bt + 3at) + a
     -> f(t) = t³(d - 3c + 3b - a) + t²(3c - 6b + 3a) - t(3b + 3a) + a
     
     
     Each resulting equation in parentheses are the extracted coefficients from our
     original formula! By doing this, we've converted our cubic bezier formula to
     something a lot easier to use:
     */
    func coefficients(for axis: Axes) -> Coefficients {
        // u³ + 3tu² + 3t²u + t³
        let c0 = (axis == .horizontalAxis) ? self.c0.x : self.c0.y
        let c1 = (axis == .horizontalAxis) ? self.c1.x : self.c1.y
        let c2 = (axis == .horizontalAxis) ? self.c2.x : self.c2.y
        let c3 = (axis == .horizontalAxis) ? self.c3.x : self.c3.y
        
        return Coefficients(
            a: c3 - 3.0*c2 + 3.0*c1 - c0,
            b: 3.0*c2 - 6.0*c1 + 3.0*c0,
            c: 3.0*c1 - 3.0*c0,
            d: c0
        )
    }
    
    /**
     We already know the representation of a bezier curve is au³ + 3btu² + 3ct²u + dt³.
     Since we converted that to at³ + bt² + ct + d through our coefficients(from:)
     function, that means all we have left is to plug in our t in order to get our
     exact point on the curve at that time.
     */
    func pointOnCurve(for time: Double) -> Progress {
        guard time > 0 && time < 1 else {
            let value = time.clamped(to: 0...1)
            return Progress(
                relativeTime: value,
                relativeValue: value
            )
        }
        
        let xCoefficients = coefficients(for: .horizontalAxis)
        let yCoefficients = coefficients(for: .verticalAxis)
        let combinedCoefficients = zip(xCoefficients.all, yCoefficients.all)
        
        var relativeTime = 0.0
        var relativeValue = 0.0
        var index = 3
        
        combinedCoefficients.forEach { coefficient in
            let xCoefficient = coefficient.0
            let yCoefficient = coefficient.1
            let tValue = time^Double(index)
            
            relativeTime += xCoefficient * tValue
            relativeValue += yCoefficient * tValue
            
            index -= 1
        }
        return Progress(
            relativeTime: relativeTime,
            relativeValue: relativeValue
        )
    }

    /**
     Getting the value for our curve that aligns with the x coordinate of our
     t requires a bit of cleverness.
     
     If we imagine our t (time) as a vertically straight line starting from (t, 0)
     to (t, maxControlPointY), then we can instead find the intersection of that line
     and the curve by doing the following:
     
     1. translate the line and the curve together to where the bottom of the line
     is at [0,0].
     2. rotate the curve and the line 90 degrees. This puts the line flush with
     the x axis.
     3. get the roots of that new rotated curve. This works because we're looking for
     the point in the rotated curve where the result of its y function == 0. Once we
     have that, then we have our new offset time!
     
     Finally, we just plug that value into our bezier formula & we have the right point!
     */
    public func progress(at time: Double) -> Progress {
        guard time > 0 && time < 1 else {
            return pointOnCurve(for: time.clamped(to: 0...1))
        }
    
        /**
         Our first root is the value of the point on the curve where its x coordinate
         matches our t. To calculate this we

         1. Translate the control points so the entire curve aligns with the origin such
         that the yAxis intersects the point we want on the graph.
         
         2. Conjugate our transform by taking the translated control points and rotating them
         around the origin at 90 degrees. Now the roots of the curve (its zeroes) coincide
         with the intersection coordinate we're trying to find.
         */
        let alignedCurve = CubicBezierCurve(points: controlPoints.map {
            return $0.translatedBy(dx: -time).rotatedAroundOrigin()
        })
        return alignedCurve.pointOnCurve(for: alignedCurve.root)
    }
}
