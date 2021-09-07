//
//  DrawerPanGestureHandler.swift
//
//  Created by Roman Filippov on 20.08.2021.
//

import UIKit

public final class DrawerPanGestureHandler: DrawerHandler {
    
    /// Maximum indentation by which user can exceed the allowed value.
    /// Also that value calculated with a smooth effect.
    public var maxBouncesOffset: CGFloat = 40

    
    override func prepare() {
        super.prepare()
    }
    
    @objc public func handleDrawerPanGesture(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            prepare()
            helper.startMoving()
        case .changed:
            var newTranslate = startValue + recognizer.translation(in: recognizer.view).offset(by: helper.axis) * (helper.inverseReceivedOffset ? -1 : 1)
            if newTranslate > maxDrawerTranslate {
                newTranslate = maxDrawerTranslate + smooth(x: newTranslate - maxDrawerTranslate, bound: maxBouncesOffset)
            } else if newTranslate < minDrawerTranslate {
                newTranslate = minDrawerTranslate + smooth(x: newTranslate - minDrawerTranslate, bound: -maxBouncesOffset)
            }
            helper.set(value: newTranslate)
        default:
            let velocity = recognizer.velocity(in: recognizer.view).offset(by: helper.axis) / 1000 * (helper.inverseReceivedOffset ? -1 : 1)
            var newTranslate: CGFloat
            if velocity > 1 {
                newTranslate = maxDrawerTranslate
            } else if velocity < -1 {
                newTranslate = minDrawerTranslate
            } else {
                newTranslate = helper.nearestAnchorPosition()
            }
            helper.setWithAnimation(value: newTranslate, velocity: velocity)
            helper.endMoving()
        }
    }
    
    
    /// https://www.desmos.com/calculator/ii6gvu0atp
    private func smooth(x: CGFloat, bound: CGFloat) -> CGFloat {
        let a = (x < 0 ? -1 : 1) * abs(bound)
        return -pow(a, 2) / (x + a) + a
    }
}

extension DrawerPanGestureHandler: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let g = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = g.velocity(in: g.view)
        switch helper.axis {
        case .horizontal:
            return abs(velocity.x) > abs(velocity.y)
        case .vertical:
            return abs(velocity.x) < abs(velocity.y)
        }
    }
    
}
