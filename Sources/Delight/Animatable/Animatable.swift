public protocol Animatable {
    associatedtype Value where Value.Progression == Progression, Self == Value
    associatedtype Progression: BinaryFloatingPoint & Animatable where Progression.Stride == Progression

    func lerp(to value: Value, with progression: Progression) -> Value
}

extension Float: Animatable {}
extension Double: Animatable {}

extension Animatable where Self: BinaryFloatingPoint {
    public func lerp(to value: Self, with progress: Self) -> Self {
        return self + (value - self) * progress
    }
}
