public protocol KeyPathProvider: Animatable {
    associatedtype PathValue: Animatable
    static var keyPaths: [WritableKeyPath<Self, PathValue>] { get }
}

extension KeyPathProvider where Self == Value, PathValue == Progression {
    public func lerp(to value: Self, with progress: Progression) -> Self {
        var newValue = self
        Self.keyPaths.forEach { keyPath in
            let start = self[keyPath: keyPath]
            let end = value[keyPath: keyPath]
            let interpolatedValue = start.lerp(to: end, with: progress)

            newValue[keyPath: keyPath] = interpolatedValue
        }

        return newValue
    }
}
