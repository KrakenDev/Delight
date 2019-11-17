//
//  StarPath.swift
//  Components
//
//  Created by Hector Matos on 11/17/18.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import Foundation

//Next there's the code for creating the CGPath of a star by creating the two arrays of points contained within polygons of two different sizes:
func starPath(for shapeLayer: CAShapeLayer, points: Int = 5) -> CGPath {
    let starPath = UIBezierPath()

    let center = CGPoint(x: shapeLayer.bounds.width / 2.0, y: shapeLayer.bounds.height / 2.0)

    let numberOfPoints = CGFloat(points)
    let numberOfLineSegments = Int(numberOfPoints * 2.0)
    let theta = .pi / numberOfPoints

    let circumscribedRadius = center.x - 16.0
    let outerRadius = circumscribedRadius * 1.039
    let excessRadius = outerRadius - circumscribedRadius
    let innerRadius = CGFloat(outerRadius * 0.382)

    let leftEdgePointX = (center.x + cos(4.0 * theta) * outerRadius) + excessRadius
    let horizontalOffset = leftEdgePointX / 2.0

    // Apply a slight horizontal offset so the star appears to be more
    // centered visually
    let offsetCenter = CGPoint(x: center.x - horizontalOffset, y: center.y)

    // Alternate between the outer and inner radii while moving evenly along the
    // circumference of the circle, connecting each point with a line segment
    for i in 0..<numberOfLineSegments {
        let radius = i % 2 == 0 ? outerRadius : innerRadius

        let pointX = offsetCenter.x + cos(CGFloat(i) * theta) * radius
        let pointY = offsetCenter.y + sin(CGFloat(i) * theta) * radius
        let point = CGPoint(x: pointX, y: pointY)

        if i == 0 {
            starPath.move(to: point)
        } else {
            starPath.addLine(to: point)
        }
    }

    starPath.close()

    // Rotate the path so the star points up as expected
    var pathTransform  = CGAffineTransform.identity
    pathTransform = pathTransform.translatedBy(x: center.x, y: center.y)
    pathTransform = pathTransform.rotated(by: CGFloat(-.pi / 2.0))
    pathTransform = pathTransform.translatedBy(x: -center.x, y: -center.y)

    starPath.apply(pathTransform)

    return starPath.cgPath
}
