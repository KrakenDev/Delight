//
//  CubicBezierSolver.c
//  Delight
//
//  Created by Hector Matos on 03/01/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

#include <tgmath.h>
#include <stdbool.h>
#include "CubicBezierSolver.h"

typedef enum {
    XAxis,
    YAxis
} Axis;

typedef struct {
    double a;
    double b;
    double c;
    double d;
} CubicCoefficients;


#pragma mark - Bezier Calculation Helpers

static inline bool floatIsUniform(double value) {
    return 0 <= value && value <= 1;
}

static inline double complex rootOfUnity(int i) {
    return (i > 0) ? (-1 + I*sqrt(3)*pow(-1, i)) / 2 : 1;
}

static inline CControlPoint translatedControlPoint(CControlPoint controlPoint, double tx, double ty)
{
    return (CControlPoint){
        .x = controlPoint.x + tx,
        .y = controlPoint.y + ty
    };
}

static inline CControlPoint rotatedControlPointAroundOriginByDegrees(CControlPoint controlPoint, double degrees)
{
    double radians = degrees * M_PI / 180;
    return (CControlPoint){
        .x = controlPoint.x * cos(radians) - controlPoint.y * sin(radians),
        .y = controlPoint.x * sin(radians) + controlPoint.y * cos(radians)
    };
}

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


#pragma mark - Cubic Bezier Solver Functions

/******************************THE Cubic Bezier Solver******************************/

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
static inline CubicCoefficients coefficientsFromCurve(CCubicBezierCurve curve, Axis axis)
{
    // u³ + 3tu² + 3t²u + t³
    double c0 = (axis == XAxis) ? curve.c0.x : curve.c0.y;
    double c1 = (axis == XAxis) ? curve.c1.x : curve.c1.y;
    double c2 = (axis == XAxis) ? curve.c2.x : curve.c2.y;
    double c3 = (axis == XAxis) ? curve.c3.x : curve.c3.y;

    return (CubicCoefficients){
        .a = c3 - 3*c2 + 3*c1 - c0,
        .b = 3*c2 - 6*c1 + 3*c0,
        .c = 3*c1 - 3*c0,
        .d = c0
    };
}

/**
 We already know the representation of a bezier curve is au³ + 3btu² + 3ct²u + dt³.
 Since we converted that to at³ + bt² + ct + d through our coefficients(from:)
 function, that means all we have left is to plug in our t in order to get our
 exact point on the curve at that time.
 */
CCurvePoint CurvePointOnBezierCurveAtT(CCubicBezierCurve curve, double t)
{
    if (t <= 0 || t >= 1) {
        double value = fmin(fmax(0, t), 1);
        return (CCurvePoint){ .relativeTime = value, .relativeValue = value };
    }

    CubicCoefficients xCoefficients = coefficientsFromCurve(curve, XAxis);
    CubicCoefficients yCoefficients = coefficientsFromCurve(curve, YAxis);

    double combinedCoefficients[4][2] = {
        { xCoefficients.a, yCoefficients.a },
        { xCoefficients.b, yCoefficients.b },
        { xCoefficients.c, yCoefficients.c },
        { xCoefficients.d, yCoefficients.d }
    };

    double relativeTime = 0;
    double relativeValue = 0;

    for (int i = 3; i >= 0; i--) {
        double xCoefficient = combinedCoefficients[3-i][0];
        double yCoefficient = combinedCoefficients[3-i][1];
        double tValue = pow(t, i);

        relativeTime += xCoefficient * tValue;
        relativeValue += yCoefficient * tValue;
    }
    return (CCurvePoint){
        .relativeTime = relativeTime,
        .relativeValue = relativeValue
    };
}

/**
 The formula for a cubic function's roots is below. The code you find
 has been translated from Cardano's solution to the cubic equation that
 I found here: https://trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm#7_u3
 */
static inline double rootForCurve(CCubicBezierCurve curve)
{
    /**
     To begin solving for 0 in a cubic equation, we need divide our coefficients by a.
     This gives us less coefficients to work with without changing the value of the roots.
     */
    CubicCoefficients coefficients = coefficientsFromCurve(curve, YAxis);
    double a = coefficients.b / coefficients.a;
    double b = coefficients.c / coefficients.a;
    double c = coefficients.d / coefficients.a;

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
    double simpleRoot = -a/3;

    double p = (3*b - a*a) / 9;
    double q = (2*a*a*a - 9*a*b + 27*c) / 54;
    double root = 0;
    double discriminant = pow(p, 3) + pow(q, 2); // Δ

    for (int i = 0; i <= 2; i++) {
        double complex possibleRoot;

        if (3*p == 0 || 2*q == 0) {
            double complex pIsZeroRoot = cbrt(-2*q) * rootOfUnity(i);
            double complex qIsZeroRoot = pow(-1, i) * sqrt(-3*p) * fmin(i, 1);
            possibleRoot = (p == 0) ? pIsZeroRoot : qIsZeroRoot;
        } else if (discriminant == 0) {
            // Δ = 0: 3 real roots, but two of them are equal
            double power = (i == 0) ? 1 : 2;
            possibleRoot = pow(2, 2 - power) * cbrt(q*pow(-1, power));
        } else if (creal(discriminant) > 0) {
            // Δ > 0: 1 real root, 2 imaginary roots
            double complex u = cbrt(sqrt(discriminant) - q) * rootOfUnity(i);
            double complex v = cbrt(sqrt(discriminant) + q) * conj(rootOfUnity(i));
            possibleRoot = u - v;
        } else {
            // Δ < 0: 3 real unique roots
            double r = sqrt(pow(fabs(p), 3));
            double phi = acos(-q/r) + 2*(i)*M_PI; // Φ
            possibleRoot = 2 * cbrt(r) * cos(phi/3);
        }

        possibleRoot += simpleRoot;

        if (cimag(possibleRoot) == 0 && floatIsUniform(creal(possibleRoot))) {
            root = creal(possibleRoot);
        }
    }

    return creal(root);
}


#pragma mark - External API

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
CCurvePoint CurvePointIntersectingCurveAtT(CCubicBezierCurve curve, double t)
{
    if (t <= 0 || t >= 1) {
        return CurvePointOnBezierCurveAtT(curve, fmin(fmax(0, t), 1));
    }

    /**
     Translate the control points so the entire curve aligns with the origin such
     that the yAxis intersects the point we want on the graph.
     */
    double tx = -t;
    CControlPoint translatedControlPoints[4] = {
        translatedControlPoint(curve.c0, tx, 0),
        translatedControlPoint(curve.c1, tx, 0),
        translatedControlPoint(curve.c2, tx, 0),
        translatedControlPoint(curve.c3, tx, 0)
    };

    /**
     Conjugate our transform by taking the translated control points and rotating them
     around the origin at 90 degrees. Now the roots of the curve (its zeroes) coincide
     with the intersection coordinate we're trying to find.
     */
    double degrees = 90;
    CCubicBezierCurve alignedCurve = (CCubicBezierCurve){
        .c0 = rotatedControlPointAroundOriginByDegrees(translatedControlPoints[0], degrees),
        .c1 = rotatedControlPointAroundOriginByDegrees(translatedControlPoints[1], degrees),
        .c2 = rotatedControlPointAroundOriginByDegrees(translatedControlPoints[2], degrees),
        .c3 = rotatedControlPointAroundOriginByDegrees(translatedControlPoints[3], degrees)
    };

    /**
     Our first root is the value of the point on the curve where its x coordinate
     matches our t.
     */
    double timeOffset = (t != 0 && t != 1) ? rootForCurve(alignedCurve) : t;
    return CurvePointOnBezierCurveAtT(curve, timeOffset);
}
