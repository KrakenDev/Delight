import PlaygroundSupport
import UIKit
import Components

let curvePlayground = CurvePlayground(viewSize: UIScreen.main.bounds.size)
curvePlayground.drawGraphView()
curvePlayground.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
PlaygroundPage.current.liveView = curvePlayground.view
