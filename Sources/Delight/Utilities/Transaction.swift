import Foundation

public protocol Transactor {
    static var disableActions: Bool { get set }
    static var animationDuration: Double { get set }
    static var completionBlock: AnimationBlock? { get set }

    static func begin()
    static func commit()
}
