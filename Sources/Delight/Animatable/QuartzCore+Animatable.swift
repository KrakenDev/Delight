import CoreGraphics
import QuartzCore

extension CGFloat: Animatable {}

extension ControlPoint: KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, Double>] = [\.x, \.y]
}

extension CGPoint: KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.x, \.y]
}

extension CGVector: KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.dx, \.dy]
}

extension CGAffineTransform: KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [\.a, \.b, \.c, \.d, \.tx, \.ty]
}

extension CATransform3D: KeyPathProvider {
    public static let keyPaths: [WritableKeyPath<Self, CGFloat>] = [
        \.m11, \.m12, \.m13, \.m14,
        \.m21, \.m22, \.m23, \.m24,
        \.m31, \.m32, \.m33, \.m34,
        \.m41, \.m42, \.m43, \.m44
    ]
}

extension CGSize: Animatable {
    // Impossible to have negative sizes
    public func lerp(to value: CGSize, with progression: CGFloat) -> CGSize {
        return CGSize(
            width: max(0.0, width.lerp(to: value.width, with: progression)),
            height: max(0.0, height.lerp(to: value.height, with: progression))
        )
    }
}

extension CGRect: Animatable {
    public func lerp(to value: CGRect, with progression: CGFloat) -> CGRect {
        return CGRect(
            origin: origin.lerp(to: value.origin, with: progression),
            size: size.lerp(to: value.size, with: progression)
        )
    }
}
