import Foundation
import UIKit
import Delight

let padding: CGFloat = 64.0

public class CurvePlayground {
    let graphMultiplier: CGFloat = 5.0
    let entireViewSize: CGSize
    let timeline = UIView(frame: .zero)
    let descriptionLabel = UILabel()

    public let view: UIView

    lazy var graphSize = (50.0 * graphMultiplier)
    public lazy var graphView = GraphView(
        bezierCurve: .easeInEaseOut,
        frame: CGRect(origin: .zero, size: CGSize(width: graphSize, height: graphSize))
    )

    public init(viewSize: CGSize) {
        entireViewSize = viewSize
        
        // Setup playground view so we have a live view to play with
        view = UIView(frame: CGRect(origin: .zero, size: entireViewSize))
        view.backgroundColor = .white

        setup()
    }

    func setup() {
        // Setup Graph View for our Curve
        graphView.layer.borderColor = krakenFadedGray.cgColor
        graphView.layer.borderWidth = 1.0
        graphView.center = CGPoint(x: entireViewSize.width / 2.0, y: entireViewSize.height / 2.0)
        graphView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]

        timeline.backgroundColor = krakenDeepGray

        descriptionLabel.textColor = krakenDeepGray
        descriptionLabel.numberOfLines = 0

        setUpSubviews()
    }

    // Use deCasteljau to generate all of the lerp line endpoints
    func lineEndpoints(for p: [ControlPoint], at t: Double, currentEndpoints: [LineEndpoints] = []) -> [LineEndpoints] {
        guard p.count >= 2 else { return currentEndpoints }
        var newEndpoints = currentEndpoints

        for index in 1...p.count - 1 {
            newEndpoints.append((p[index - 1].cgPoint, p[index].cgPoint))
        }

        var newPoints: [ControlPoint] = []
        for i in 0...p.count - 2 {
            newPoints.append(p[i].lerp(to: p[i+1], with: CGFloat(t)))
        }
        return lineEndpoints(for: newPoints, at: t, currentEndpoints: newEndpoints)
    }

    public func drawGraphView() {
        let lerpLines = lineEndpoints(for: graphView.bezierCurve.controlPoints, at: 0.0).map(graphView.addLine)
        let lineLayers = lerpLines.map(graphView.layer(from:))
        let linearReferencePoint = graphView.plot(krakenGreen, dotAt: .zero)

        graphView.updateFunction = { time in
            // New Lerp Lines
            let newLineEndings = self.lineEndpoints(for: self.graphView.bezierCurve.controlPoints, at: time)
            lerpLines.enumerated().forEach {
                self.graphView.move($0.element.layer, to: newLineEndings[$0.offset])
            }

            let curvePoint = self.graphView.bezierCurve.progress(at: Double(time))
            linearReferencePoint.center = self.graphView.coordinate(for: ControlPoint(x: CGFloat(curvePoint.relativeTime), y: CGFloat(curvePoint.relativeValue)))

            let lowestPoint = [linearReferencePoint.center, CGPoint(x: 0.0, y: self.graphView.bounds.height)].max(by: CGPoint.increasingOrder(forAxis: .y))?.y ?? 0.0
            let highestPoint = [linearReferencePoint.center, CGPoint(x: 0.0, y: self.graphView.bounds.height)].min(by: CGPoint.increasingOrder(forAxis: .y))?.y ?? 0.0

            // Move timeline to show our current t
            var timelineFrame = self.timeline.frame
            if !self.graphView.isMovingControlPoint {
                timelineFrame.origin.x = self.graphView.frame.minX + self.graphSize * CGFloat(time)
            }
            timelineFrame.origin.y = self.graphView.frame.minY + min(highestPoint, lowestPoint)
            timelineFrame.size.width = 1.0
            timelineFrame.size.height = lowestPoint - highestPoint
            self.timeline.frame = timelineFrame

            self.descriptionLabel.text = "progress:\n\(curvePoint)\ncontrolPoints:\n\t\(self.graphView.bezierCurve.c0)\n\t\(self.graphView.bezierCurve.c1)\n\t\(self.graphView.bezierCurve.c2)\n\t\(self.graphView.bezierCurve.c3)"

            var labelSize = self.descriptionLabel.sizeThatFits(CGSize(width: self.graphView.bounds.width, height: .infinity))
            labelSize.width = self.graphView.bounds.width

            self.descriptionLabel.frame = CGRect(origin: self.descriptionLabel.frame.origin, size: labelSize)
            self.descriptionLabel.center = CGPoint(
                x: self.graphView.segmentedControl.center.x,
                y: self.graphView.segmentedControl.frame.maxY + (labelSize.height / 2.0) + padding / 4.0
            )
        }

        lineLayers.forEach {
            graphView.layer.addSublayer($0)
            $0.strokeColor = krakenFadedGray.cgColor
        }
    }

    func setUpSubviews() {
        view.addSubview(timeline)
        view.addSubview(graphView)
        graphView.addSubview(descriptionLabel)
    }
}
