//
//  Animations+Delight.swift
//  Delight
//
//  Created by Hector Matos on 02/14/2018.
//  Copyright © 2018 KrakenDev, LLC. All rights reserved.
//

import Foundation
import UIKit

typealias View = UIView

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

extension UIOffset: Animatable, KeyPathProvider {
    public static let keyPaths = [\horizontal, \vertical]
}

extension UIEdgeInsets: Animatable, KeyPathProvider {
    public static let keyPaths = [\top, \left, \bottom, \right]
}

extension UIView: Displayable, Preparable {
    public static var maxFPS: Int {
        guard #available(iOS 10.3, *) else { return 60 }
        return UIScreen.main.maximumFramesPerSecond
    }

    static func prepare() {
        let oldActionForKey = #selector(CALayer.action(forKey:))
        let newActionForKey = #selector(CALayer.delightfulAction(forKey:))
        swizzle(CALayer.self, .instance, method: oldActionForKey, with: newActionForKey)
    }

    static func cleanup() {
        let oldActionForKey = #selector(CALayer.delightfulAction(forKey:))
        let newActionForKey = #selector(CALayer.action(forKey:))
        swizzle(CALayer.self, .instance, method: oldActionForKey, with: newActionForKey)
    }
}
