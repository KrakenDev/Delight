#if canImport(AppKit)
import AppKit
import Foundation

typealias View = NSView

extension NSEdgeInsets: Animatable, KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.top, \.left, \.bottom, \.right]
}

extension View: Displayable {
    public static var inheritedAnimationDuration: Double {
        NSAnimationContext.current.duration
    }
}

extension NSColor: Segmentable {
    public func segmented(by amount: Int) -> [NSColor] {
        var hue: CGFloat = 0.0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return stride(from: 0.0, to: 1.0, by: 1.0/CGFloat(amount)).map {
            NSColor(hue: hue + $0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
    }
}
#endif
