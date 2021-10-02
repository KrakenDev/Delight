import Foundation

protocol Overlappable {
    func overlaps(_ overlappable: Self) -> Bool
}

class UnsafeBox<T> {
    private(set) var unbox: T

    init(_ value: T) {
        unbox = value
    }

    /// Use this method to mutate the boxed value.
    func unboxedValue(_ mutation: (inout T) -> Void) {
        mutation(&unbox)
    }
}

extension Collection {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { return $0[keyPath: keyPath] }
    }

    func deferred(_ execution: @escaping (Self) -> Void) -> VoidBlock {
        return { execution(self) }
    }
}

extension Array where Element: Equatable {
    mutating func append(removingPossibleDuplicate element: Element) {
        defer { append(element) }
        guard let mostRecent = last, mostRecent == element else { return }
        removeLast()
    }
}

extension BinaryFloatingPoint {
    var isUniform: Bool {
        (0.0...1.0).contains(self)
    }

    var degrees: Self { self * 180.0 / .pi }
    var radians: Self { self * .pi / 180.0 }

    var removedSlop: Self {
        guard !isZero else { return .zero }
        return (self * 1000).rounded() / 1000
    }


    func trim(digitsPastDecimal places: Int) -> Self {
        Darwin.round(self * 10.0 * Self(places)) / (10.0 * Self(places))
    }

    func clamped(to range: ClosedRange<Self>) -> Self {
        range.contains(self) ? self : min(
            max(range.lowerBound, self),
            range.upperBound
        )
    }
}

enum MethodType {
    case instance
    case `class`
}

func execute(block: VoidBlock) { block() }
func identity<T>(for object: T) -> T { return object }

func swizzle(_ clazz: AnyClass, _ type: MethodType, method originalSelector: Selector, with newSelector: Selector) {
    guard let originalMethod = class_getInstanceMethod(clazz, originalSelector), let newMethod = class_getInstanceMethod(clazz, newSelector) else { return }

    if class_addMethod(clazz, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
        class_replaceMethod(clazz, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, newMethod)
    }
}
