//
//  Subpath.swift
//  Delight
//
//  Created by Hector Matos on 11/26/18.
//

import Foundation
import CoreGraphics

class Path: Segmentable {
    var segments: [PathElement]
    var subpaths: [[PathElement]] = []
    var segmentedCache: [Int : [PathElement]] = [:]

    init(elements: [PathElement] = []) {
        self.segments = elements
    }

    func segmented(by amount: Int) -> [PathElement] {
        guard amount != segments.count && segmentedCache[amount] == nil else { return segmentedCache[amount] ?? segments }

        var addExtraPart = false
        var remainder = (amount - 1) % (segments.count - 1)
        let baseAmount = (amount - 1) / (segments.count - 1)

        guard baseAmount > 1 || remainder > 0 else { return segments }

        var newSegments: [PathElement] = [segments.first ?? .init()]

        for segment in segments.dropFirst() {
            addExtraPart = remainder > 0

            let segmentAmount = baseAmount + (addExtraPart ? 1 : 0)
            let subSegments = segment.segmented(by: segmentAmount)
            newSegments.append(contentsOf: subSegments)

            remainder -= subSegments.count == segmentAmount ? 1 : subSegments.count - segmentAmount
        }

        segmentedCache[amount] = newSegments
        return newSegments
    }
}

extension Path: CustomStringConvertible {
    var description: String {
        return "\(subpaths)"
    }
}
