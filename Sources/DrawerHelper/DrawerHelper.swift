import UIKit

public protocol DrawerHelperDelegate: AnyObject {
    /// Tells the delegate when the user moved drawer.
    /// - Parameters:
    ///   - drawerHelper: The drawerHelper object in which the translation occurred
    ///   - progress: Progress of value from closed to opened state.
    /// Also this method is called under animation transaction if need
    func drawerHelper(_ drawerHelper: DrawerHelper, didChangeTransitionProgress progress: Float)
    
    func drawerHelperStartMoving(_ drawerHelper: DrawerHelper)
    func drawerHelperEndMoving(_ drawerHelper: DrawerHelper)
}
public extension DrawerHelperDelegate {
    func drawerHelper(_ drawerHelper: DrawerHelper, didChangeTransitionProgress progress: Float) {}
    func drawerHelperStartMoving(_ drawerHelper: DrawerHelper) {}
    func drawerHelperEndMoving(_ drawerHelper: DrawerHelper) {}
}

public final class DrawerHelper {
    
    private let receiver: DrawerValueReceiver
    let axis: Axis
    
    /// value for closed drawer state
    public var initialValue: CGFloat
    
    /// offset from initialValue for fully open drawer state
    public var maximumOffset: CGFloat
    
    /// middle positions between open and closed states
    public var steps: [Step]
    
    /// The damping ratio for the spring animation as it approaches its quiescent state.
    /// To smoothly decelerate the animation without oscillation, use a value of 1.
    /// Employ a damping ratio closer to zero to increase oscillation.
    public var dampingRatio: CGFloat = 0.7
    
    /// sqrt from points per second
    public var animationSpeed: CGFloat = 600
    
    
    public weak var delegate: DrawerHelperDelegate?
    
    private(set) public lazy var panGestureHandler = DrawerPanGestureHandler(helper: self)
    private(set) public lazy var scrollViewHandler = DrawerScrollHandler(helper: self)
    
    public struct Step {
        /// percentage of distance between open and closed state
        public let multiplier: CGFloat
        /// offset from result of applying multiplier
        public let offset: CGFloat
        public init(multiplier: CGFloat = 0, offset: CGFloat = 0) {
            self.multiplier = multiplier
            self.offset = offset
        }
    }
    
    
    public enum Receiver {
        /// will change transform of view to translate it in drawer position
        case transform(UIView)
        /// will change constraint constant in drawer position. inverted if constant is increasing from right to left or from bottom to top
        case constraint(NSLayoutConstraint, inverted: Bool)
    }
    
    
    public enum Axis {
        case horizontal
        case vertical
    }
    
    
    /// - Parameters:
    ///   - receiver: value receiver that updates drawerView position
    ///   - axis: axis along which the drawer will be moved
    ///   - initialValue: value for closed drawer state
    ///   - maximumOffset: offset from initial value that drawer can be moved to open state
    ///   - steps: steps between open and close states that drawer can be stoped
    public init(receiver: Receiver, axis: Axis, initialValue: CGFloat = 0, maximumOffset: CGFloat, steps: [Step] = []) {
        switch receiver {
        case .transform(let view):
            self.receiver = DrawerValueReceiverTransform(drawerView: view, axis: axis)
        case .constraint(let constraint, let inverted):
            self.receiver = DrawerValueReceiverConstraint(drawerConstraint: constraint, invertedConstant: inverted)
        }
        self.axis = axis
        self.initialValue = initialValue
        self.maximumOffset = maximumOffset
        self.steps = steps
    }
    
    /// - Parameters:
    ///   - receiver: value receiver that updates drawerView position
    ///   - axis: axis along which the drawer will be moved
    ///   - initialValue: value for closed drawer state
    ///   - maximumOffset: offset from initial value that drawer can be moved to open state
    ///   - steps: steps between open and close states that drawer can be stoped
    public init(receiver: DrawerValueReceiver, axis: Axis, initialValue: CGFloat = 0, maximumOffset: CGFloat, steps: [Step] = []) {
        self.receiver = receiver
        self.axis = axis
        self.initialValue = initialValue
        self.maximumOffset = maximumOffset
        self.steps = steps
    }
    
    internal var minDrawerTranslate: CGFloat {
        min(initialValue, initialValue + maximumOffset)
    }
    internal var maxDrawerTranslate: CGFloat {
        max(initialValue, initialValue + maximumOffset)
    }
    
    internal func valueFor(step: Step) -> CGFloat {
        initialValue + step.offset + maximumOffset * step.multiplier
    }
    
    public var transitionProgress: Float {
        Float((receiver.currentValue - initialValue) / maximumOffset)
    }
    
}

extension DrawerHelper {
    
    public func openDrawer(animated: Bool = true) {
        setValue(initialValue + maximumOffset, animated: animated)
    }
    public func closeDrawer(animated: Bool = true) {
        setValue(initialValue, animated: animated)
    }
    public func setStep(index: Int, animated: Bool = true) {
        if index >= steps.count {
            assertionFailure()
            return
        }
        setValue(valueFor(step: steps[index]), animated: animated)
    }
    
    private func setValue(_ value: CGFloat, animated: Bool) {
        if animated {
            setWithAnimation(value: value)
        } else {
            receiver.set(value: value)
        }
    }

}

internal extension DrawerHelper {
    
    var currentValue: CGFloat { receiver.currentValue }
    var inverseReceivedOffset: Bool { receiver.inverseReceivedOffset }
    
    func startMoving() {
        delegate?.drawerHelperStartMoving(self)
    }
    
    func endMoving() {
        delegate?.drawerHelperEndMoving(self)
    }
    
    func set(value: CGFloat) {
        receiver.set(value: value)
        delegate?.drawerHelper(self, didChangeTransitionProgress: transitionProgress)
    }
    
    func setWithAnimation(value: CGFloat, velocity: CGFloat = 0, underAnimation: (()->Void)? = nil) {
        let duration = sqrt(abs(receiver.currentValue - value) / animationSpeed)
        receiver.set(value: value, withAnimationDuration: duration, dampingRatio: dampingRatio, velocity: velocity) {
            underAnimation?()
            self.delegate?.drawerHelper(self, didChangeTransitionProgress: self.transitionProgress)
        }
    }
    
    func nearestAnchorPosition() -> CGFloat {
        var position = receiver.currentValue > (maximumOffset/2 + initialValue) ? maxDrawerTranslate : minDrawerTranslate
        var minDelta = abs(position - receiver.currentValue)
        for step in steps {
            let stepPosition = valueFor(step: step)
            let delta = abs(stepPosition - receiver.currentValue)
            if minDelta > delta {
                position = stepPosition
                minDelta = delta
            }
        }
        return position
    }

}
