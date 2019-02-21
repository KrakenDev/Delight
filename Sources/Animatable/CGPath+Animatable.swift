//
//  CGPath+Animatable.swift
//  Delight
//
//  Created by Hector Matos on 9/14/18.
//

import Foundation
import CoreGraphics


// MARK: CGPath Interpolation (This one's a doozy)

extension CGPath: Animatable {
    /**
     This was ripped STRAIGHT from https://oleb.net/blog/2015/06/c-callbacks-in-swift/
     */

    private static func appendElement(cgPathElement: UnsafePointer<CGPathElement>, path: Path) {
        let type = cgPathElement.pointee.type
        let points = cgPathElement.pointee.points
        let previous = path.segments.last ?? .init()

        let pathSegment: PathElement

        switch type {
        case .moveToPoint:
            pathSegment = .init(
                operation: .move,
                destination: points[0]
            )
        case .addLineToPoint:
            pathSegment = .init(
                operation: .addLine,
                origin: previous.destination,
                destination: points[0]
            )
        case .addQuadCurveToPoint:
            pathSegment = .init(
                operation: .addQuadCurve,
                origin: previous.destination,
                control1: points[0],
                destination: points[1]
            )
        case .addCurveToPoint:
            pathSegment = .init(
                operation: .addCurve,
                origin: previous.destination,
                control1: points[0],
                control2: points[1],
                destination: points[2]
            )
        case .closeSubpath:
            pathSegment = .init(
                operation: .closeSubpath,
                origin: previous.destination,
                destination: path.subpaths.last?.first?.destination ?? .zero
            )
        }

        var lastSubpath = path.subpaths.popLast() ?? []
        if type != .moveToPoint && path.segments.isEmpty {
            lastSubpath.append(previous)
        }
        lastSubpath.append(pathSegment)

        path.subpaths.append(lastSubpath)
        path.segments.append(pathSegment)

        if type == .closeSubpath {
            path.subpaths.append([])
        }
    }

    private var path: Path {
        let convertPath = Path()

        if #available(iOS 11.0, *) {
            applyWithBlock {
                CGPath.appendElement(cgPathElement: $0, path: convertPath)
            }
        } else {
            // Wrap the array in a Box & wrap the Box in an Unmanaged instance
            let unmanaged = Unmanaged.passRetained(UnsafeBox(convertPath))
            apply(info: unmanaged.toOpaque()) { userInfo, element in
                guard let userInfo = userInfo else { return }
                Unmanaged<UnsafeBox<Path>>.fromOpaque(userInfo).takeUnretainedValue().unboxedValue {
                    CGPath.appendElement(cgPathElement: element, path: $0)
                }
            }
        }

        if convertPath.subpaths.last?.isEmpty == true {
            convertPath.subpaths.removeLast()
        }

        return convertPath
    }

    /**
     Now back to our regularly scheduled Hector programming.
     */
    public func lerp(to value: CGPath, with progress: CGFloat) -> CGPath {
        let fromPath = path
        let toPath = value.path

        guard !fromPath.segments.isEmpty && !toPath.segments.isEmpty else {
            return value
        }

        let newPath = CGMutablePath()
        var fromSegments = fromPath.segments
        var toSegments = toPath.segments

        if fromSegments.count != toSegments.count {
            let partCount = Swift.max(fromSegments.count, toSegments.count)
            fromSegments = fromPath.segmented(by: partCount)
            toSegments = toPath.segmented(by: partCount)
            allPaths.append(newPath)
        }

        for (fromSegment, toSegment) in zip(fromSegments, toSegments) {
            let newSegment = fromSegment.lerp(to: toSegment, with: progress)
            newSegment.add(to: newPath)
        }

        return newPath
    }
}

public var allPaths: [CGPath] = []
