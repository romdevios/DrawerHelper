//
//  Utils.swift
//  
//  Created by Roman Filippov on 14.08.2021.
//

import UIKit

internal extension CGPoint {
    func offset(by axis: DrawerHelper.Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return x
        case .vertical:
            return y
        }
    }
    mutating func setOffset(by axis: DrawerHelper.Axis, value: CGFloat) {
        switch axis {
        case .horizontal:
            self.x = value
        case .vertical:
            self.y = value
        }
    }
}

extension UIScrollView {
    
    func setOffset(by axis: DrawerHelper.Axis, value: CGFloat, animated: Bool) {
        switch axis {
        case .horizontal:
            setContentOffset(CGPoint(x: value, y: contentOffset.y), animated: animated)
        case .vertical:
            setContentOffset(CGPoint(x: contentOffset.x, y: value), animated: animated)
        }
    }
}
