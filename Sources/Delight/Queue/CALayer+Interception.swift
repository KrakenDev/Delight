import QuartzCore

extension CALayer {
    @objc open func delightfulAction(forKey keyPath: String) -> CAAction? {
        struct FailedEnqueue: Error { }
        guard let container = AnimationQueue.enclosingAnimation(),
            let oldValue = value(forKey: keyPath)
            else { return delightfulAction(forKey: keyPath) }

        var hasher = Hasher()
        hasher.combine(self)
        hasher.combine(keyPath)

        let hashValue = hasher.finalize()

        func enqueueing<T: Animatable>(with possibleValue: T?) {
            guard let value = possibleValue else { return }

            let valueProvider = LayerValueProvider { [weak self] in
                self?.value(forKey: keyPath) as? T ?? value
            }

            let keyframe = LayerKeyframe<T>(valueProvider: valueProvider, hashValue: hashValue)
            container.addAnimation(for: keyframe) { [weak self] relatedKeyframes in
                let animation = CAKeyframeAnimation(keyPath: keyPath)
                animation.duration = container.timing.totalDuration

                animation.values = relatedKeyframes.reduce([T]()) {
                    return $0 + $1.animation.values.dropLast()
                }
                animation.keyTimes = relatedKeyframes.reduce([NSNumber]()) {
                    return $0 + $1.animation.keyTimes
                        .map(Double.init)
                        .map(NSNumber.init(value:))
                        .dropLast()
                }
                
                self?.add(animation, forKey: keyPath)
            }
        }

        enqueueing(with: oldValue as? CGFloat)
        enqueueing(with: oldValue as? ControlPoint)
        enqueueing(with: oldValue as? CGPoint)
        enqueueing(with: oldValue as? CGSize)
        enqueueing(with: oldValue as? CGRect)
        enqueueing(with: oldValue as? CGVector)
        enqueueing(with: oldValue as? CGAffineTransform)
        enqueueing(with: oldValue as? CATransform3D)
        enqueueing(with: oldValue as? Double)
        enqueueing(with: oldValue as? Float)
        enqueueing(with: CGPath.value(from: oldValue))
        enqueueing(with: CGColor.value(from: oldValue))

        return delightfulAction(forKey: keyPath)
    }
}

private protocol CFTypeProtocol {
    static var typeID: CFTypeID { get }
}

extension CGPath: CFTypeProtocol {}
extension CGColor: CFTypeProtocol {}
extension CFTypeProtocol {
    static func value<T>(from valueToCast: T) -> Self? {
        guard CFGetTypeID(valueToCast as CFTypeRef) == typeID else { return nil }
        return valueToCast as? Self
    }
}
