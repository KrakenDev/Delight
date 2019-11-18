//
//  Delight+Utilities.swift
//  Delight
//
//  Created by Hector Matos on 9/14/18.
//

import Complex
import Foundation
import UIKit

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

enum MethodType {
    case instance
    case `class`
}

public protocol Segmentable {
    associatedtype Segment: Segmentable
    func segmented(by amount: Int) -> [Segment]
}

protocol CFTypeProtocol {
    static var typeID: CFTypeID { get }
}

protocol Overlappable {
    func overlaps(_ overlappable: Self) -> Bool
}

protocol Preparable {
    static func prepare()
    static func cleanup()
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

extension CFTypeProtocol {
    static func value<T>(from valueToCast: T) -> Self? {
        guard CFGetTypeID(valueToCast as CFTypeRef) == typeID else { return nil }
        return valueToCast as? Self
    }
}

extension CGPath: CFTypeProtocol {}
extension CGColor: CFTypeProtocol {}

extension CAShapeLayer: Segmentable {
    public func segmented(by amount: Int) -> [CAShapeLayer] {
        guard let segments = path?.path.segments else { return [self] }
        
        var layers: [CAShapeLayer] = []
        for (segment, color) in zip(segments, UIColor.white.segmented(by: segments.count)) {
            let debugCurveLayer = CAShapeLayer()
            debugCurveLayer.lineWidth = 3.0
            debugCurveLayer.strokeColor = color.cgColor
            debugCurveLayer.fillColor = UIColor.clear.cgColor
            
            let curve = segment.bezierCurve
            let mutableBezierPath = UIBezierPath()
            mutableBezierPath.move(to: curve.c0.cg)
            mutableBezierPath.addCurve(to: curve.c3.cg, controlPoint1: curve.c1.cg, controlPoint2: curve.c2.cg)
            
            debugCurveLayer.path = mutableBezierPath.cgPath
            layers.append(removingPossibleDuplicate: debugCurveLayer)
        }
        
        return layers
    }
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
