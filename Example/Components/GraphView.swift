import Delight
import Foundation
import UIKit

// Make our types pretty
typealias LineEndpoints = (start: CGPoint, end: CGPoint)
typealias Line = (layer: CAShapeLayer, endpoints: LineEndpoints)
typealias GraphControlPoint = (view: UIView, index: Int)
typealias ReferenceDots = (endpoint: UIView, intercept: UIView, curvePoint: UIView, timeIntercept: UIView)

// colors
let krakenBackgroundColor = UIColor(red: 36/255, green: 52/255, blue: 71/255, alpha: 1.0)
let krakenFadedGray = UIColor(red: 225/255, green: 232/255, blue: 237/255, alpha: 1.0)
let krakenDeepGray = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
let krakenBlue = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
let krakenPurple = UIColor(red: 121/255, green: 75/255, blue: 196/255, alpha: 1.0)
let krakenRed = UIColor(red: 224/255, green: 36/255, blue: 94/255, alpha: 1.0)
let krakenGreen = UIColor(red: 23/255, green: 191/255, blue: 99/255, alpha: 1.0)

let queue = DispatchQueue(label: "com.krakendev.delight.animations")

enum AnimationType: String {
    case scale
    case position
    case path

    static let allItems: [AnimationType] = [.path, .scale, .position]
}

struct Movement: OptionSet {
    let rawValue: UInt

    static let toTheLeft    = Movement(rawValue: 1 << 0)
    static let toTheRight   = Movement(rawValue: 1 << 1)
    static let upwards      = Movement(rawValue: 1 << 2)
    static let downwards    = Movement(rawValue: 1 << 3)
}

extension CGPoint {
    func moved(_ movement: Movement, by distance: CGFloat) -> CGPoint {
        var position = self

        if movement.contains(.toTheLeft) {
            position.x -= distance
        }
        if movement.contains(.toTheRight) {
            position.x += distance
        }
        if movement.contains(.upwards) {
            position.y -= distance
        }
        if movement.contains(.downwards) {
            position.y += distance
        }

        return position
    }
}

class AnimatingCircle: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }

    lazy var star: CGPath = starPath(for: layer, points: 5)
    lazy var circle: CGPath = {
        let offset = CGFloat(16.0)
        let radius = ((bounds.width * 2/3) / 2.0) - offset
        let viewCenter = CGPoint(x: radius + offset * 1.5, y: radius + offset * 1.5)

        let angleForTheTopOfTheCircle: CGFloat = .pi * 1.5
        let wholeCircleAngle: CGFloat = .pi * 2.0
        let endAngle = angleForTheTopOfTheCircle + wholeCircleAngle

        let circlePath = UIBezierPath(
            arcCenter: viewCenter,
            radius: radius,
            startAngle: angleForTheTopOfTheCircle,
            endAngle: endAngle,
            clockwise: true
        ).cgPath

        guard let mutableCirclePath = circlePath.mutableCopy() else { return circlePath }

        let topCenter = viewCenter.moved(.toTheRight, by: radius)
        let rightCenter = topCenter.moved([.downwards, .toTheRight], by: radius)
        let bottomCenter = rightCenter.moved([.downwards, .toTheLeft], by: radius)
        let leftCenter = bottomCenter.moved([.upwards, .toTheLeft], by: radius)

        let topRightCurve = CubicBezierCurve(points: [topCenter, .zero, .zero, rightCenter]).circleApproximation.pathElement
        let bottomRightCurve = CubicBezierCurve(points: [rightCenter, .zero, .zero, bottomCenter]).circleApproximation.pathElement
        let bottomLeftCurve = CubicBezierCurve(points: [bottomCenter, .zero, .zero, leftCenter]).circleApproximation.pathElement
        let topLeftCurve = CubicBezierCurve(points: [leftCenter, .zero, .zero, topCenter]).circleApproximation.pathElement

        mutableCirclePath.move(to: topCenter)
        topRightCurve.add(to: mutableCirclePath)
        bottomRightCurve.add(to: mutableCirclePath)
        bottomLeftCurve.add(to: mutableCirclePath)
        topLeftCurve.add(to: mutableCirclePath)

        return mutableCirclePath
    }()

    lazy var heart: CGPath = {
        let heartPath = UIBezierPath()
        //Scaling will take bounds from the originalRect passed
        let originalRect = bounds
        let scaledWidth = (originalRect.width * CGFloat(0.8))
        let scaledXValue = ((originalRect.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.height * CGFloat(0.65))
        let scaledYValue = ((originalRect.height) - scaledHeight) / 2

        let scaledRect = CGRect(
            x: scaledXValue,
            y: scaledYValue,
            width: scaledWidth,
            height: scaledHeight
        )
        heartPath.move(
            to: CGPoint(
                x: originalRect.width/2,
                y: scaledRect.minY + scaledRect.height
            )
        )

        heartPath.addCurve(
            to: CGPoint(
                x: scaledRect.minX,
                y: scaledRect.minY + (scaledRect.height/4)
            ),
            controlPoint1: CGPoint(x: scaledRect.minX + (scaledRect.width/2), y: scaledRect.minY + (scaledRect.height*3/4)),
            controlPoint2: CGPoint(x: scaledRect.minX, y: scaledRect.minY + (scaledRect.height/2))
        )

        heartPath.addArc(
            withCenter: CGPoint(
                x: scaledRect.minX + (scaledRect.width/4),
                y: scaledRect.minY + (scaledRect.height/4)
            ),
            radius: (scaledRect.width/4),
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )

        heartPath.addArc(
            withCenter: CGPoint(
                x: scaledRect.minX + (scaledRect.width * 3/4),
                y: scaledRect.minY + (scaledRect.height/4)),
            radius: (scaledRect.width/4),
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        heartPath.addCurve(
            to: CGPoint(
                x: originalRect.width/2,
                y: scaledRect.minY + scaledRect.height),
            controlPoint1: CGPoint(x: scaledRect.minX + scaledRect.width, y: scaledRect.minY + (scaledRect.height/2)),
            controlPoint2: CGPoint(x: scaledRect.minX + (scaledRect.width/2), y: scaledRect.minY + (scaledRect.height*3/4)) )
        heartPath.close()
        return heartPath.cgPath
    }()
}

public class GraphView: UIView {
    var animationType: AnimationType
    var updateFunction: ((Double) -> Void) = { _ in }
    var animateFunction: () -> () -> Void = { return {} }
    var bezierCurve: CubicBezierCurve = .zero {
        didSet {
            if oldValue != bezierCurve {
                updateCurve()
            }
        }
    }
    var lowestPoint: CGPoint = .zero
    var highestPoint: CGPoint = .zero
    var controlPoints: [GraphControlPoint] = []
    var curveLine = CAShapeLayer()
    var progress: Delight.Progress<Double> = .start()
    var startedTapInsideCircles = false
    var startedGestureInsideGraph = true
    var isMovingControlPoint: Bool {
        return movingControlPoint != nil
    }

    lazy var segmentedControl = UISegmentedControl(items: AnimationType.allItems.map(rawValue))
    lazy var animatingCircle = AnimatingCircle(frame: CGRect(origin: .zero, size: bounds.size))
    lazy var paths = [animatingCircle.heart, animatingCircle.star, animatingCircle.circle]

    var movingControlPoint: GraphControlPoint?
    var startTime: Double = 0.0
    var currentOrigin: Double = 0.0
    var currentTime: Double = 0.0
    var currentDuration: Double {
        return CATransaction.animationDuration * 10.0
    }

    public override var frame: CGRect {
        didSet {
            segmentedControl.center = CGPoint(x: bounds.width / 2.0, y: bounds.height + segmentedControl.bounds.height + 8.0)
        }
    }

    required init(bezierCurve: CubicBezierCurve, frame: CGRect) {
        animationType = .position

        super.init(frame: frame)

        animationType = AnimationType.allItems.first ?? .position

        var bezierCurve = bezierCurve
        lowestPoint = bezierCurve.controlPoints.map(CGPoint.init).min(by: CGPoint.increasingOrder(forAxis: .y)) ?? .zero
        highestPoint = bezierCurve.controlPoints.map(CGPoint.init).max(by: CGPoint.increasingOrder(forAxis: .y)) ?? .zero

        self.curveLine.fillColor = UIColor.clear.cgColor
        self.curveLine.strokeColor = krakenBlue.cgColor
        self.curveLine.lineWidth = 3.0

        self.bezierCurve = bezierCurve
        self.controlPoints = bezierCurve.controlPoints.enumerated().map { (plot(krakenBlue, dotAt: $0.element), $0.offset) }

        backgroundColor = .clear
        layer.borderColor = krakenBlue.cgColor
        layer.borderWidth = 3.0

        clipsToBounds = false

        animatingCircle.backgroundColor = .clear
        animatingCircle.layer.path = paths.first
        animatingCircle.layer.fillColor = UIColor.clear.cgColor
        animatingCircle.layer.strokeColor = krakenPurple.cgColor

        let dragGesture = UILongPressGestureRecognizer(target: self, action: #selector(tapped(_:)))
        dragGesture.minimumPressDuration = 0.001
        dragGesture.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(dragGesture)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = krakenDeepGray
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)

        addSubview(animatingCircle)
        addSubview(segmentedControl)
        layer.addSublayer(curveLine)
    }

    @objc func segmentedControlDidChange() {
        progressAnimation(animated: true, time: 0.0)
        animationType = AnimationType.allItems[segmentedControl.selectedSegmentIndex]
    }

    func rawValue(from animationType: AnimationType) -> String {
        return animationType.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        animationType = .position
        super.init(coder: aDecoder)
    }

    func updateCurve() {
        curveLine.path = path(for: bezierCurve)
        layer.insertSublayer(curveLine, at: 0)
    }

    func progressAnimation(animated: Bool = false, time: Double = 0.0) {
        let oldTime = currentTime
        let bezier: CubicBezierCurve = startedTapInsideCircles && (progress.relativeTime == 0.0 || progress.relativeTime == 1.0) ? self.bezierCurve : .easeInEaseOut

        currentTime = time
        progress = bezierCurve.progress(at: currentTime)

        let duration = animated ? currentDuration : 0.0
        let curve: TimingCurve = .cubic(bezier)
        let animateToOld = oldTime >= 0.5

        UIView.animate(withDuration: duration, curve: curve) {
            switch self.animationType {
            case .path:
                allPaths = []
                self.currentIndex = 0

                let relativeDuration = 1.0 / Double(self.paths.count - 1)

                for startIndex in 0..<self.paths.count - 1 {
                    let relativeStartTime = Double(startIndex) * relativeDuration
                    
                    UIView.addKeyframe(
                        withRelativeStartTime: relativeStartTime,
                        relativeDuration: relativeDuration,
                        curve: .cubic(.linear)) {
                        let index = animateToOld ? self.paths.count - 2 - startIndex : startIndex + 1
                        self.animatingCircle.layer.path = self.paths[index]
                    }
                }
            case .scale:
                let oldPosition: CGAffineTransform = .identity
                let newPosition = CGAffineTransform(scaleX: 4.0, y: 4.0)
                if !animated {
                    self.animatingCircle.transform = oldPosition.lerp(to: newPosition, with: CGFloat(self.progress.relativeValue))
                } else {
                    self.animatingCircle.transform = animateToOld ? oldPosition : newPosition
                }
            case .position:
                let getPosition: (Bool) -> CGPoint = {
                    return CGPoint(
                        x: self.bounds.width / 2.0,
                        y: $0 ? self.bounds.height : self.bounds.height / 2.0
                    )
                }

                let oldPosition = getPosition(false)
                let newPosition = getPosition(true)

                if !animated {
                    self.animatingCircle.center = oldPosition.lerp(to: newPosition, with: CGFloat(self.progress.relativeValue))
                } else {
                    self.animatingCircle.center = animateToOld ? oldPosition : newPosition
                }
            }

            let timingProgressions = bezier.progressions(from: duration).map { $0.relativeTime }
            let frameProgressions = zip(timingProgressions.dropLast(), timingProgressions.dropFirst())

            for (relativeStartTime, nextStartTime) in frameProgressions {
                UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: nextStartTime - relativeStartTime, curve: .cubic(.linear)) {
                    self.updateFunction(oldTime.lerp(to: self.currentTime, with: nextStartTime))
                }
            }
        }
    }

    class CustomGesture: UITapGestureRecognizer {}

    var currentIndex = 0

    @discardableResult func plot(_ color: UIColor, dotAt point: ControlPoint, size: CGFloat = 8.0) -> UIView {
        let plotPointSize = CGSize(width: size, height: size)
        let newPlotPoint = UIView(frame: CGRect(origin: .zero, size: plotPointSize))
        newPlotPoint.backgroundColor = color
        newPlotPoint.layer.cornerRadius = plotPointSize.height / 2.0

        newPlotPoint.center = coordinate(for: point)
        addSubview(newPlotPoint)
        return newPlotPoint
    }

    func path(for curve: CubicBezierCurve) -> CGPath {
        let c0 = coordinate(for: curve.c0)
        let c1 = coordinate(for: curve.c1)
        let c2 = coordinate(for: curve.c2)
        let c3 = coordinate(for: curve.c3)

        let path = CGMutablePath()
        path.move(to: c0)
        path.addCurve(to: c3, control1: c1, control2: c2)

        return path
    }

    func coordinate(for relativePoint: ControlPoint) -> CGPoint {
        var relativeCenter = relativePoint
        relativeCenter.y *= -1.0

        let sizeVector = CGPoint(x: frame.width, y: frame.height)
        var viewCenter = relativeCenter.cgPoint * sizeVector
        viewCenter.y += frame.width
        return viewCenter
    }

    func addLine(for endPoints: LineEndpoints) -> Line {
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.lightGray.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(lineLayer)
        return move(lineLayer, to: endPoints)
    }

    @discardableResult func move(_ lineLayer: CAShapeLayer, to endpoints: LineEndpoints) -> Line {
        let path = CGMutablePath()
        let start = coordinate(for: endpoints.start.controlPoint)
        let end = coordinate(for: endpoints.end.controlPoint)

        path.move(to: start)
        path.addLine(to: end)

        lineLayer.path = path
        return (lineLayer, (start, end))
    }

    func layer(from line: Line) -> CAShapeLayer {
        return line.layer
    }

    func controlPoint(at location: CGPoint) -> GraphControlPoint? {
        return controlPoints.first {
            let inset = CGFloat(9.0)
            var dotFrame = $0.view.frame
            dotFrame.origin.x -= inset
            dotFrame.origin.y -= inset
            dotFrame.size.width += inset * 2.0
            dotFrame.size.height += inset * 2.0
            return dotFrame.contains(location)
        }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let padding: CGFloat = 12.0
        let lowestY = coordinate(for: lowestPoint.controlPoint).y
        let highestY = coordinate(for: highestPoint.controlPoint).y
        return point.x >= bounds.minX - padding && point.x <= bounds.maxX + padding && point.y >= highestY - padding && point.y <= max(lowestY, segmentedControl.frame.maxY) + padding
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        updateCurve()
        updateFunction(currentTime)
    }

    @objc public func tapped(_ gesture: UIGestureRecognizer) {
        let oldTime = currentTime
        let gestureLocation = gesture.location(in: self)
        var unitLocation = gestureLocation
        unitLocation.x = min(max(0.0, gestureLocation.x) / frame.width, 1.0)
        unitLocation.y = (frame.height - gestureLocation.y) / frame.height

        let location = coordinate(for: unitLocation.controlPoint)

        if gesture.state == .began {
            startTime = Double(unitLocation.x)
            currentOrigin = currentTime
            startedGestureInsideGraph = point(inside: gestureLocation, with: nil) && !segmentedControl.frame.contains(gestureLocation)

            var initiatedAnimationFrame = bounds
            initiatedAnimationFrame.origin.x = bounds.width/3.0
            initiatedAnimationFrame.size.width = bounds.width/3.0
            startedTapInsideCircles = initiatedAnimationFrame.contains(gestureLocation)
        }

        guard startedGestureInsideGraph else { return }

        if gesture.state == .ended {
            guard movingControlPoint == nil else {
                movingControlPoint = nil
                return
            }

            lowestPoint = bezierCurve.controlPoints.map(CGPoint.init).min(by: CGPoint.increasingOrder(forAxis: .y)) ?? .zero
            highestPoint = bezierCurve.controlPoints.map(CGPoint.init).max(by: CGPoint.increasingOrder(forAxis: .y)) ?? .zero

            if startedTapInsideCircles {
                progressAnimation(animated: true, time: currentTime >= 0.5 ? 0.0 : 1.0)
                return
            } else if !allPaths.isEmpty {
                currentIndex = gestureLocation.x <= bounds.width / 2.0 ? currentIndex - 1 : currentIndex + 1
                currentIndex = min(max(currentIndex, 0), allPaths.count - 1)
                self.animatingCircle.layer.path = allPaths[currentIndex]
            }
        } else if let movingControlPoint = movingControlPoint {
            movingControlPoint.view.center = location
            bezierCurve.controlPoints[movingControlPoint.index] = CGPoint(x: unitLocation.x, y: unitLocation.y).controlPoint
        } else if gesture.state != .began, let dot = controlPoint(at: location), dot.index == 1 || dot.index == 2 {
            movingControlPoint = dot
        } else if !startedTapInsideCircles && gesture.state != .began {
            currentTime = min(max(currentOrigin + (Double(unitLocation.x) - startTime), 0.0), 1.0)
        }

        if oldTime != currentTime || isMovingControlPoint {
            progressAnimation(time: currentTime)
        }
    }
}
