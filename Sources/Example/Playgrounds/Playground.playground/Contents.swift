import PlaygroundSupport
import UIKit

let curvePlayground = CurvePlayground(viewSize: UIScreen.main.bounds.size)
curvePlayground.drawGraphView()
curvePlayground.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
PlaygroundPage.current.liveView = curvePlayground.view
