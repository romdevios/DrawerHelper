//
//  DrawerValueReceiver.swift
//  
//  Created by Roman Filippov on 14.08.2021.
//

import UIKit

public protocol DrawerValueReceiver {
    var currentValue: CGFloat { get }
    /// Will invert received translation from panGestureRecognizer
    var inverseReceivedOffset: Bool { get }
    func set(value: CGFloat)
    func set(value: CGFloat, withAnimationDuration duration: CGFloat, dampingRatio: CGFloat, velocity: CGFloat, underAnimation: @escaping ()->Void)
}

extension DrawerValueReceiver {
    var inverseReceivedOffset: Bool { false }
    func set(value: CGFloat, withAnimationDuration duration: CGFloat, dampingRatio: CGFloat, velocity: CGFloat, underAnimation: @escaping ()->Void) {
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: abs(velocity)) {
            self.set(value: value)
            underAnimation()
        }
    }
}

final class DrawerValueReceiverTransform: DrawerValueReceiver {
    
    private weak var drawerView: UIView?
    private(set) var currentValue: CGFloat = 0
    private let axis: DrawerHelper.Axis
    
    init(drawerView: UIView, axis: DrawerHelper.Axis) {
        self.drawerView = drawerView
        self.axis = axis
    }

    func set(value: CGFloat) {
        currentValue = value
        if value == 0 {
            drawerView?.transform = .identity
        } else {
            switch axis {
            case .horizontal:
                drawerView?.transform = .init(translationX: value, y: 0)
            case .vertical:
                drawerView?.transform = .init(translationX: 0, y: value)
            }
        }
    }
    
}

final class DrawerValueReceiverConstraint: DrawerValueReceiver {
    
    private weak var drawerConstraint: NSLayoutConstraint?
    let inverseReceivedOffset: Bool
    
    var currentValue: CGFloat {
        drawerConstraint?.constant ?? 0
    }
    
    init(drawerConstraint: NSLayoutConstraint, invertedConstant: Bool) {
        self.drawerConstraint = drawerConstraint
        self.inverseReceivedOffset = invertedConstant
    }

    func set(value: CGFloat) {
        drawerConstraint?.constant = value
        
        let firstItem = (drawerConstraint?.firstItem as? UIView) ?? (drawerConstraint?.firstItem as? UILayoutGuide)?.owningView
        let secondItem = (drawerConstraint?.secondItem as? UIView) ?? (drawerConstraint?.secondItem as? UILayoutGuide)?.owningView
        switch (firstItem, secondItem) {
        case (.some(let firstItem), .some(let secondItem)):
            if firstItem.hierarchicalParent(of: secondItem) {
                firstItem.layoutIfNeeded()
            } else {
                secondItem.layoutIfNeeded()
            }
        case (.some(let item), .none),
             (.none, .some(let item)):
            item.layoutIfNeeded()
        default:
            break
        }
    }
    
}

private extension UIView {
    
    func hierarchicalParent(of otherView: UIView) -> Bool {
        if let otherSuperview = otherView.superview {
            if otherSuperview === self {
                return true
            } else {
                return hierarchicalParent(of: otherSuperview)
            }
        } else {
            return false
        }
    }
    
}
