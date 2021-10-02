import CoreGraphics

extension CGColor: Animatable {
    public func lerp(to value: CGColor, with progress: Double) -> CGColor {
        guard let toColorSpace = value.colorSpace else { return value }
        return CGColor(
            colorSpace: toColorSpace,
            components: zip(components ?? [], value.components ?? []).map {
                $0.0.lerp(to: $0.1, with: CGFloat(progress))
            }
        ) ?? value
    }
}
