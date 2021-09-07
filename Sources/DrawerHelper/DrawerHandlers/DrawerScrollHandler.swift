//
//  DrawerScrollHandler.swift
//
//  Created by Roman Filippov on 14.08.2021.
//

import UIKit

open class DrawerScrollHandler: DrawerHandler, UIScrollViewDelegate, UITableViewDelegate, UICollectionViewDelegate, UITextViewDelegate {
    
    /// rule on how the scroll should stick to value updates
    public var stickingMode = StickingMode.scrollStart
    /// direction of scrolling start
    public var direction = ScrollDirection.forward
    
    private var ignoreSrollChanges: Bool = false
    private var lastOffsetOnEdge: CGFloat = 0
    
    public enum StickingMode {
        /// Will change position of the drawer instead of scrolling and keep an offset equal to zero when moving within the allowed range.
        case scrollStart
        /// Will change position of the drawer instead of scrolling only after the finger reaches the edge of scrollView.
        /// If you need to scroll when the drawer is in the middle position and expand it only if a finger has reached an edge of a scrollView
        case touchOnEdge
        /// Will use `touchOnEdge` snap mode for drawer open transition and `scrollStart` for closing drawer
        case touchOnEdgeForOpen
    }
    
    public enum ScrollDirection {
        /// normal scrollView direction
        case forward
        /// scrolling starts from bottom of scrollView
        case backward
    }

    internal override func prepare() {
        super.prepare()
        ignoreSrollChanges = false
        lastOffsetOnEdge = 0
    }
    
    private func initialOffset(_ scrollView: UIScrollView) -> CGFloat {
        switch direction {
        case .forward:
            return scrollView.minimumOffset(by: helper.axis)
        case .backward:
            return scrollView.maximumOffset(by: helper.axis)
        }
    }
    private func isOpeningState(_ scrollView: UIScrollView, newTranslate: CGFloat, offset: CGFloat) -> Bool {
        let limitOffset = initialOffset(scrollView)
        let viewScrolled: Bool
        switch direction {
        case .forward:
            viewScrolled = offset <= limitOffset
        case .backward:
            viewScrolled = offset >= limitOffset
        }
        return minDrawerTranslate...startValue ~= newTranslate &&
        (viewScrolled || lastOffsetOnEdge == limitOffset)
    }
    private func isClosingState(_ scrollView: UIScrollView, newTranslate: CGFloat) -> Bool {
        let signInversion: CGFloat = (helper.inverseReceivedOffset ? -1 : 1)
        let location = scrollView.panGestureRecognizer.location(in: scrollView)
        let movedToClose: Bool
        switch direction {
        case .forward:
            movedToClose = (startValue * signInversion) <= (helper.currentValue * signInversion)
                || (startValue * signInversion) <= (newTranslate * signInversion)
        case .backward:
            movedToClose = (startValue * signInversion) >= (helper.currentValue * signInversion)
                || (startValue * signInversion) >= (newTranslate * signInversion)
        }
        return scrollView.bounds.contains(location) && movedToClose
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        prepare()
        helper.startMoving()
        switch stickingMode {
        case .touchOnEdge, .touchOnEdgeForOpen:
            lastOffsetOnEdge = scrollView.contentOffset.offset(by: helper.axis)
        case .scrollStart:
            lastOffsetOnEdge = initialOffset(scrollView)
            
            let offset = scrollView.contentOffset.offset(by: helper.axis)
            if offset != lastOffsetOnEdge {
                let signInversion: CGFloat = (helper.inverseReceivedOffset ? -1 : 1)
                var newTranslate = helper.currentValue - (offset - lastOffsetOnEdge) * signInversion
                var newOffset = lastOffsetOnEdge
                if newTranslate > maxDrawerTranslate {
                    newTranslate = maxDrawerTranslate
                    let diff = abs(newTranslate - helper.currentValue)
                    switch direction {
                    case .forward:
                        newOffset = offset - diff
                    case .backward:
                        newOffset = offset + diff
                    }
                }
                if newTranslate != helper.currentValue {
                    helper.setWithAnimation(value: newTranslate) {
                        scrollView.contentOffset.setOffset(by: self.helper.axis, value: newOffset)
                    }
                }
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ignoreSrollChanges {
            return
        }
        let signInversion: CGFloat = (helper.inverseReceivedOffset ? -1 : 1)
        let limitOffset = initialOffset(scrollView)
        let offset = scrollView.contentOffset.offset(by: helper.axis)
        
        var newTranslate = helper.currentValue - (offset - lastOffsetOnEdge) * signInversion
        
        if stickingMode == .touchOnEdgeForOpen,
           isOpeningState(scrollView, newTranslate: newTranslate, offset: offset) {
            lastOffsetOnEdge = limitOffset
        } else if stickingMode != .scrollStart,
            isClosingState(scrollView, newTranslate: newTranslate) {
            lastOffsetOnEdge = offset
            helper.set(value: startValue)
            return
        }
        
        if newTranslate > maxDrawerTranslate {
            newTranslate = maxDrawerTranslate
        } else if newTranslate < minDrawerTranslate {
            newTranslate = minDrawerTranslate
        } else {
            scrollView.setOffset(by: helper.axis, value: lastOffsetOnEdge, animated: false)
        }
        helper.set(value: newTranslate)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        ignoreSrollChanges = true
        let offset = scrollView.contentOffset.offset(by: helper.axis)
        if stickingMode == .scrollStart {
            let limitOffset = initialOffset(scrollView)
            switch direction {
            case .forward:
                if offset > limitOffset { return }
            case .backward:
                if offset < limitOffset { return }
            }
        }
        
        let signInversion: CGFloat = (helper.inverseReceivedOffset ? -1 : 1)
        let velocity = velocity.offset(by: helper.axis)
//        let targetOffset = targetContentOffset.pointee.offset(by: helper.axis)
//        let targetTranslate = helper.currentValue - (targetOffset - lastOffsetOnEdge) * signInversion
        
        var newTranslate = helper.currentValue - (offset - lastOffsetOnEdge) * signInversion
        if stickingMode != .scrollStart,
           isClosingState(scrollView, newTranslate: newTranslate),
           stickingMode != .touchOnEdgeForOpen || !isOpeningState(scrollView, newTranslate: newTranslate, offset: offset) {
            return
        }
        
        switch (direction, velocity) {
        case (.forward, 1...),
             (.backward, ...(-1)):
            newTranslate = maxDrawerTranslate
        case (.forward, ...(-1)),
             (.backward, 1...):
            newTranslate = minDrawerTranslate
        default:
            newTranslate = helper.nearestAnchorPosition()
            if stickingMode != .scrollStart {
                scrollView.setOffset(by: helper.axis, value: lastOffsetOnEdge, animated: false)
            }
        }
        if stickingMode == .scrollStart {
            targetContentOffset.pointee.setOffset(by: helper.axis, value: lastOffsetOnEdge)
        }
        helper.setWithAnimation(value: newTranslate, velocity: velocity)
        helper.endMoving()
    }
    
}

private extension UIScrollView {
    
    func minimumOffset(by axis: DrawerHelper.Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return -self.contentInset.left
        case .vertical:
            return -self.contentInset.top
        }
    }
    
    func maximumOffset(by axis: DrawerHelper.Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return contentSize.width + contentInset.right - bounds.width
        case .vertical:
            return contentSize.height + contentInset.bottom - bounds.height
        }
    }
    
}
