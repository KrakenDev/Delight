import CoreGraphics
import Foundation

protocol CGConvertible {
    associatedtype CoreGraphicsType
    var cg: CoreGraphicsType { get }
}

extension ControlPoint: CGConvertible {
    var cg: CGPoint { .init(x: x, y: y) }
}

extension CGConvertible where Self: BinaryFloatingPoint {
    var cg: CGFloat { .init(self) }
}

extension Float: CGConvertible {}
extension Double: CGConvertible {}
