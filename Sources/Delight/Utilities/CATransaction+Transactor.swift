import QuartzCore

typealias Transaction = CATransaction

extension CATransaction: Transactor {
    public static var disableActions: Bool {
        get { return disableActions() }
        set { setDisableActions(newValue) }
    }
    public static var animationDuration: Double {
        get { return animationDuration() }
        set { setAnimationDuration(newValue) }
    }
    public static var completionBlock: AnimationBlock? {
        get { return completionBlock() }
        set { setCompletionBlock(newValue) }
    }
}
