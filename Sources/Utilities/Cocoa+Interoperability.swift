//
//  Cocoa+Delight.swift
//  Delight
//
//  Created by Hector Matos on 9/13/18.
//

import Cocoa

typealias View = NSView

private var inheritedDuration = 0.0

extension NSView: Animator {
    public static var inheritedAnimationDuration: TimeInterval {
        get { return inheritedDuration }
        set { inheritedDuration = newValue }
    }

    public static func setAnimationDuration(_ duration: TimeInterval) {
        guard duration > 0.0 else { return }
        inheritedAnimationDuration = duration
    }

    public static var maxFPS: Int {
        let display = CGDisplayCopyDisplayMode(CGMainDisplayID())
        return Int(display?.refreshRate ?? 60.0)
    }
}
