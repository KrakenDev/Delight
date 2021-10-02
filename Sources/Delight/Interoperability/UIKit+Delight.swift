#if canImport(UIKit)
import Foundation
import UIKit

typealias View = UIView

extension UIOffset: Animatable, KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.horizontal, \.vertical]
}

extension UIEdgeInsets: Animatable, KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.top, \.left, \.bottom, \.right]
}

extension View: Displayable {
    public static var maxFPS: Int {
        guard #available(iOS 10.3, *) else { return 60 }
        return UIScreen.main.maximumFramesPerSecond
    }
}

extension CGColor {
    static let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let clear = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
    static let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
}

extension UIColor: Segmentable {
    public func segmented(by amount: Int) -> [UIColor] {
        var hue: CGFloat = 0.0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return stride(from: 0.0, to: 1.0, by: 1.0/CGFloat(amount)).map {
            UIColor(hue: hue + $0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
    }
}
#endif
