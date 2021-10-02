import Foundation
import CoreGraphics

public struct BoundingBox {
    enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
    
    let topLeft: CGPoint
    let bottomRight: CGPoint
    let center: CGPoint
    
    init(topLeft: CGPoint, bottomRight: CGPoint) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        
        self.center = CGPoint(
            x: topLeft.x.lerp(to: bottomRight.x, with: 0.5),
            y: topLeft.y.lerp(to: bottomRight.y, with: 0.5)
        )
    }
    
    func coordinate(for corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft:
            return topLeft
        case .topRight:
            return CGPoint(x: bottomRight.x, y: topLeft.y)
        case .bottomLeft:
            return CGPoint(x: topLeft.x, y: bottomRight.y)
        case .bottomRight:
            return bottomRight
        }
    }
}

public class Path {
    public var segments: [PathElement]
    var subpaths: [[PathElement]] = []
    var segmentedCache: [Int : [PathElement]] = [:]
    var boundingBox: BoundingBox = .init(topLeft: .zero, bottomRight: .zero)
    
    var highestCenteredElement: PathElement? {
        return segments.min {
            let centerDeltaA = boundingBox.center - $0.origin
            let centerDeltaB = boundingBox.center - $1.origin
            let isClosestToCenter = abs(centerDeltaA.x) <= abs(centerDeltaB.x)

            let isHigher = $0.origin.y < $1.origin.y
            let isLeftmost = $0.origin.x < $1.origin.x
            let isHigherAndLeftmost = isHigher && isLeftmost

            return (isClosestToCenter && isHigherAndLeftmost) || isHigherAndLeftmost || isHigher || isLeftmost
        }
    }

    init(elements: [PathElement] = []) {
        segments = elements
    }
    
    func updateBoundingBox() {
        let minX = segments.min { min($0.origin.x, $0.destination.x) < min($1.origin.x, $1.destination.x) }
        let maxX = segments.max { min($0.origin.x, $0.destination.x) < min($1.origin.x, $1.destination.x) }
        
        let minY = segments.min { min($0.origin.y, $0.destination.y) < min($1.origin.y, $1.destination.y) }
        let maxY = segments.max { min($0.origin.y, $0.destination.y) < min($1.origin.y, $1.destination.y) }

        boundingBox = BoundingBox(
            topLeft: CGPoint(
                x: min(minX?.origin.x ?? 0.0, minX?.destination.x ?? 0.0),
                y: min(minY?.origin.y ?? 0.0, minY?.destination.y ?? 0.0)
            ),
            bottomRight: CGPoint(
                x: max(maxX?.origin.x ?? 0.0, maxX?.destination.x ?? 0.0),
                y: max(maxY?.origin.y ?? 0.0, maxY?.destination.y ?? 0.0)
            )
        )
    }
}

extension Path: CustomStringConvertible {
   public var description: String {
        return "\(subpaths)"
    }
}
