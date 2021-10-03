import Foundation
import Numerics

extension CubicBezierCurve {
    enum Axis {
        case value
        case time
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

extension ControlPoint {
    func translatedBy(dx: Double, dy: Double = 0.0) -> ControlPoint {
        ControlPoint(x: x + dx, y: y + dy)
    }
    // In degrees
    func rotatedAroundOrigin(by angle: Double = 90.0) -> ControlPoint {
        ControlPoint(
            x: x * cos(angle.radians).removedSlop
                - y * sin(angle.radians).removedSlop,
            y: x * sin(angle.radians).removedSlop
                + y * cos(angle.radians).removedSlop
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
     We can generate our coefficients by expanding our formulas and simplifying
     them in terms of t. BTW, coefficients are the thingies you multiply tⁿ by.

     In the primer above, we're able to prove that u=(1-t) so the first step is to replace
     all 'u's with '1-t'.

     Let's see what that looks like:
     -> f(t) = au³ + 3btu² + 3ct²u + dt³
     -> f(t) = a(1-t)³ + 3bt(1-t)² + 3ct²(1-t) + dt³
     -> f(t) = a(1-2t+t²)(1-t) + 3bt(1-2t+t²) + (3ct²-3ct³) + dt³
     -> f(t) = a(1-3t+3t²-t³) + (3bt-6bt²+3bt³) + (3ct²-3ct³) + dt³
     -> f(t) = (a-3at+3at²-at³) + (3bt-6bt²+3bt³) + (3ct²-3ct³) + dt³
     -> f(t) = a + -3at + 3at² + -at³ + 3bt + -6bt² + 3bt³ + 3ct² + -3ct³ + dt³
     -> f(t) = (dt³ - 3ct³ + 3bt³ - at³) + (3ct² - 6bt² + 3at²) + (3bt - 3at) + a
     -> f(t) = t³(d - 3c + 3b - a) + t²(3c - 6b + 3a) + t(3b - 3a) + a

     Everything in parentheses from the last line above are the extracted coefficients from
     our original formula! By doing this, we've converted our cubic bezier formula to
     something a lot easier to use:

     at³ + bt² + ct + d
     */
    func coefficients(for axis: Axis) -> Coefficients {
        let a = (axis == .time) ?
            self.c0.x : self.c0.y
        let b = (axis == .time) ?
            self.c1.x : self.c1.y
        let c = (axis == .time) ?
            self.c2.x : self.c2.y
        let d = (axis == .time) ?
            self.c3.x : self.c3.y

        return Coefficients(
            a: d - 3*c + 3*b - a,
            b: 3*c - 6*b + 3*a,
            c: 3*b - 3*a,
            d: a
        )
    }

    /**
     We already know the representation of a bezier curve is au³ + 3btu² + 3ct²u + dt³.
     Since we converted that to at³ + bt² + ct + d through our `coefficients(from:)`
     function, that means all we have left is to plug in our t in order to get our
     exact point on the curve at that time.
     */
    func pointOnCurve(forTime t: Double) -> Progress {
        let x = coefficients(for: .time)
        let y = coefficients(for: .value)

        return Progress(
            relativeTime: x.a*t^^3 + x.b*t^^2 + x.c*t + x.d,
            relativeValue: y.a*t^^3 + y.b*t^^2 + y.c*t + y.d
        )
    }

    /**
     The formula for a cubic function's roots is below. The code you find
     has been translated from Cardano's solution to the cubic equation that
     I found here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#7_u3
     */
    var root: Double {
        /**
         In the link above, the author starts with x³ + ax² + bx + c. However, our coefficients and cubic formula
         are derived from the equation ax³ + bx² + cx + d

         Determining the root of a polynomial means we have to equate our formula to 0. This means we can easily transform our cubic
         formula into the equation the author starts with by dividing by a:

         -> 0 = ax³ + bx² + cx + d
         -> 0/a = (ax³ + bx² + cx + d) / a
         -> 0 = (ax³ + bx² + cx + d)(1/a)
         -> 0 = (1/a)ax³ + (1/a)bx² + (1/a)cx + (1/a)d
         -> 0 = x³ + (b/a)x² + (c/a)x + (d/a)
         -> 0 = x³ + ax² + bx + c
         */
        let coeffs = coefficients(for: .value)

        let a = coeffs.b / coeffs.a
        let b = coeffs.c / coeffs.a
        let c = coeffs.d / coeffs.a

        /**
         Now that we have values for each coefficient in the equation of the form x³ + ax² + bx + c, the math checks out to reduce
         the formula even more: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#mozTocId231308

         In that link's section, we find that we can further represent this equation with a simpler form called the "reduced cubic"
         where we substitute x for (t-a/3). In doing so, the algebra works out to this reduced cubic:
         0 = t³ + pt + q

         Where:
         p = (3b - a²) / 3
         q = (2a³ - 9ab + 27c) / 27
         */

        let p = (3*b - a^^2) / 3
        let q = (2*a^^3 - 9*a*b + 27*c) / 27

        // When reducing the cubic formula and solving for roots, this coefficient is used often.
        let coefficient = a/3

        /**
         After getting concrete values for p and q, there are some easy outs we can take to immediately extract the root of the formula but only if
         p or q is 0: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#1.%20Immediately%20Solvable
         */
        if p.isZero && q.isZero {
            return .zero
        }

        /**
         If _p is zero_, then according to the previous link our formula simplifies more:
         -> 0 = t³ + pt + q
         -> 0 = t³ + (0)t + q
         -> 0 = t³ + q
         -> -t³ = q
         -> t³ = -q
         -> t = ∛-q

         Given that we know x (our root) = `t-a/3`, we can introduce x back to this equation:
         -> t = ∛-q
         -> t - a/3 = (∛-q) - a/3
         -> x = (∛-q) - a/3

         To get all three roots of a cube root, we multiply the output of ∛x by the three cube roots of unity.
         Formula for the cube roots of unity was taken from
         https://en.wikipedia.org/wiki/Root_of_unity#Explicit_expressions_in_low_degrees

         This turns our three possible roots into:
         -> x₁ = ∛(-q) - a/3
         -> x₂ = ∛(-q)[-1/2 ± √(3)i/2] - a/3
         -> x₃ = ∛(-q)[-1/2 ± √(3)i/2] - a/3
         */
        if p.isZero {
            // Since we only care about real values, we won't bother computing roots of unity here
            print("p is zero", ∛(-q) - coefficient)
            return ∛(-q) - coefficient
        }

        /**
         If _q is zero_, then our formula simplifies more:
         -> 0 = t³ + pt + q
         -> 0 = t³ + pt + (0)
         -> 0 = t³ + pt

         For the above formula to work, then t has to equal zero:
         -> 0 = (0)³ + p(0)

         Since t = x + a/3 (derived from x=t-a/3) and we know that t must equal zero, we get our first root:
         -> 0 = x + a/3
         -> x₁ = -a/3

         But this is only one of three roots! The other two can be taken by solving for `0 = t³ + pt`
         -> 0 = t³ + pt
         -> 0/t = (t³ + pt)/t
         -> 0 = t² + p
         -> -p = t²
         -> √-p = t

         Substitute `x + a/3` for t again:
         -> √-p = t
         -> √-p = x + a/3
         -> x = √-p - a/3

         Multiply `√-p` (AKA 't') by both roots of one (-1 & 1) and you get:
         -> x₂,x₃ = ±√-p - a/3

         That leaves us with our three roots when `q` is zero:
         -> x₁ = -a/3
         -> x₂ = √-p - a/3
         -> x₃ = -√-p - a/3
         */
        if q.isZero {
            // Since we only care about real values, we won't bother computing with roots of unity here
            print("q is zero", -coefficient)
            return -coefficient
        }

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

         To get the discriminant value, this section walks through the algebra to get the discriminant from our `p` and `q` values:
         https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#2%20Equation%20in%20p%20and%20q%20where%20neither%20zero

         At the end of that section, they define the Δ to be:
         -> Δ = (q/2)² + (p/3)³
         */
        let Δ = (q/2)^^2 + (p/3)^^3

        /**
         Discriminants are denoted with Δ. The rules for finding out the properties of all three roots are as follows:

         Δ > 0: 2 real roots
         Δ = 0: 1 real root, 1 imaginary
         Δ < 0: 2 imaginary roots

         In each case of the discriminant, the solutions for the roots are translated from
         here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#The_Value_of_the_Discriminant_%CE%94
         */
        if Δ < .zero {
            // Δ < 0: 3 real unique roots
            // Taking the sqrt of Δ gives us a complex number so we have to solve this with trigonometry, instead.

            let r = √((-p/3)^^3)
            let Φ = acos(-q / 2*r)
            let π = Double.pi

            let x1 = 2 * ∛r * cos(Φ / 3) - coefficient
            let x2 = 2 * ∛r * cos((Φ + 2*π) / 3) - coefficient
            let x3 = 2 * ∛r * cos((Φ + 4*π) / 3) - coefficient

            print("Δ < .zero", x1, x2, x3)

            // We're specifically looking for the root between 0 and 1
            if (0.0...1.0).contains(x1) {
                return x1
            }
            if (0.0...1.0).contains(x2) {
                return x2
            }
            if (0.0...1.0).contains(x3) {
                return x3
            }
        } else {
            /**
             There's one last piece of the puzzle missing which is another derivation of the above formulas in which we need to find
             the values for `u` and `v` here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#mozTocId643919

             -> u = ∛(-q/2 + √Δ)
             -> v = ∛(q/2 + √Δ)

             Once we have `u` and `v` we can determine our roots using this formula as long as Δ isn't negative:
             -> x₁ = u - v - a/3
             -> x₂ = -0.5(u - v) + i√3(u + v) - a/3
             -> x₃ = -0.5(u - v) - i√3(u + v) - a/3
             */

            let u = ∛(-q/2 + √Δ)
            let v = ∛(q/2 + √Δ)
            let t = u - v

            let x1 = Complex(t - coefficient)
            let x2 = Complex(-t/2) + Complex(u + v, √3) - Complex(coefficient)
            let x3 = Complex(-t/2) - Complex(u + v, √3) - Complex(coefficient)

            print("Δ >= .zero", x1, x2, x3)

            if x1.isFinite {
                return x1.real
            }
            if x2.isFinite {
                return x2.real
            }
            if x3.isFinite {
                return x3.real
            }
        }

        print("zero")
        return .zero
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
            $0.translatedBy(dx: time).rotatedAroundOrigin()
        })
        return pointOnCurve(forTime: alignedCurve.root)
    }
}
