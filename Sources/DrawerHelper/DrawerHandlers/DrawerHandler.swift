//
//  DrawerHandler.swift
//  
//
//  Created by Roman Filippov on 20.08.2021.
//

import UIKit

open class DrawerHandler: NSObject {
    
    internal var startValue: CGFloat = 0
    internal var minDrawerTranslate: CGFloat = 0
    internal var maxDrawerTranslate: CGFloat = 0
    
    unowned let helper: DrawerHelper
    
    public init(helper: DrawerHelper) {
        self.helper = helper
    }

    internal func prepare() {
        self.startValue = helper.currentValue
        self.minDrawerTranslate = helper.minDrawerTranslate
        self.maxDrawerTranslate = helper.maxDrawerTranslate
    }
    
}
