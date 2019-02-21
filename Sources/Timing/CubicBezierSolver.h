//
//  CubicBezierSolver.h
//  Delight
//
//  Created by Hector Matos on 03/01/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

#ifndef CUBICBEZIERSOLVER_H
#define CUBICBEZIERSOLVER_H

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

typedef struct {
    double x;
    double y;
} CControlPoint;

typedef struct {
    double relativeTime;
    double relativeValue;
} CCurvePoint;

typedef struct {
    CControlPoint c0;
    CControlPoint c1;
    CControlPoint c2;
    CControlPoint c3;
} CCubicBezierCurve;

extern CCurvePoint CurvePointOnBezierCurveAtT(CCubicBezierCurve curve, double t);
extern CCurvePoint CurvePointIntersectingCurveAtT(CCubicBezierCurve curve, double t);

#if defined(__cplusplus) || defined(c_plusplus)
}  /* extern "C" */
#endif

#endif /* CUBICBEZIERSOLVER_H */
