//
//  ViewController.swift
//  DrawerExample
//
//  Created by Roman Filippov on 14.08.2021.
//

import UIKit
import DrawerHelper

final class ViewController: UIViewController {
    
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dampingRatioLabel: UILabel!
    @IBOutlet weak var animationSpeedLabel: UILabel!
    @IBOutlet weak var maxBoundsOffsetLabel: UILabel!
    
    @IBOutlet weak var dampingRatioSlider: UISlider!
    @IBOutlet weak var animationSpeedSlider: UISlider!
    @IBOutlet weak var fadingBoundsOffsetSlider: UISlider!
    
    @IBOutlet weak var handleScrollOnEdgeOnlySegment: UISegmentedControl!
    @IBOutlet weak var directionSegment: UISegmentedControl!
    @IBOutlet weak var receiverSegment: UISegmentedControl!
    
    @IBOutlet weak var drawerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerBottomConstraint: NSLayoutConstraint!
    
    var helper: DrawerHelper!
    var panGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dampingRatioSlider.value = 0.7
        animationSpeedSlider.value = 600
        fadingBoundsOffsetSlider.value = 40
        darkView.alpha = 0
    }
    
    @IBAction func dampingRatioChanged(_ sender: UISlider) {
        dampingRatioLabel.text = "dampingRatio: \(sender.value)"
    }
    @IBAction func animationSpeedChanged(_ sender: UISlider) {
        animationSpeedLabel.text = "animationSpeed: \(sender.value)"
    }
    @IBAction func maxBoundsOffsetChanged(_ sender: UISlider) {
        maxBoundsOffsetLabel.text = "maxBouncesOffset: \(sender.value)"
    }
    
    
    @IBAction func openAction() {
        drawerView.transform = .identity
        drawerLeadingConstraint.isActive = false
        drawerTrailingConstraint.isActive = false
        drawerTopConstraint.isActive = false
        drawerBottomConstraint.isActive = false
        tableView.contentInset = .init(top: 20, left: 0, bottom: 40, right: 0)
        if let panGesture = panGesture {
            drawerView.removeGestureRecognizer(panGesture)
        }
        
        let axis: DrawerHelper.Axis
        let manipulatingConstraint: NSLayoutConstraint
        let offset: CGFloat
        let invertedConstant: Bool
        switch directionSegment.selectedSegmentIndex {
        case 0: // left
            axis = .horizontal
            manipulatingConstraint = drawerLeadingConstraint
            offset = view.bounds.width - 100
            invertedConstant = false
            tableView.contentInset.left = 100
            
        case 1: // right
            axis = .horizontal
            manipulatingConstraint = drawerTrailingConstraint
            offset = view.bounds.width - 100
            invertedConstant = true
            tableView.contentInset.right = 100
            
        case 2: // top
            axis = .vertical
            manipulatingConstraint = drawerTopConstraint
            if #available(iOS 11.0, *) {
                offset = view.bounds.height - 100 - view.safeAreaInsets.top
            } else {
                offset = view.bounds.height - 100 - view.layoutMargins.top
            }
            invertedConstant = false
            tableView.contentInset.top = 120
            tableView.contentOffset.y = tableView.contentSize.height - tableView.frame.height
            
        case 3: // bottom
            axis = .vertical
            manipulatingConstraint = drawerBottomConstraint
            if #available(iOS 11.0, *) {
                offset = view.bounds.height - 100 - view.safeAreaInsets.bottom
            } else {
                offset = view.bounds.height - 100 - view.layoutMargins.bottom
            }
            invertedConstant = true
            tableView.contentInset.bottom = 120
            tableView.contentOffset.y = 0
            
        default:
            fatalError()
        }
        
        manipulatingConstraint.isActive = true
        manipulatingConstraint.constant = 0
        
        
        // MARK: - Setup helper
        
        if receiverSegment.selectedSegmentIndex == 0 {
            let sign: CGFloat = invertedConstant ? -1 : 1
            helper = .init(receiver: .transform(drawerView), axis: axis, initialValue: 32 * sign, maximumOffset: (offset - 32) * sign, steps: [.init(multiplier: 0.3)])
        } else {
            helper = .init(receiver: .constraint(manipulatingConstraint, inverted: invertedConstant), axis: axis, initialValue: 32, maximumOffset: offset - 32, steps: [.init(multiplier: 0.3)])
        }
        
        helper.delegate = self
        helper.dampingRatio = CGFloat(dampingRatioSlider.value)
        helper.animationSpeed = CGFloat(animationSpeedSlider.value)
        helper.panGestureHandler.maxBouncesOffset = CGFloat(fadingBoundsOffsetSlider.value)
        tableView.delegate = helper.scrollViewHandler
        switch handleScrollOnEdgeOnlySegment.selectedSegmentIndex {
        case 0:
            helper.scrollViewHandler.stickingMode = .scrollStart
        case 1:
            helper.scrollViewHandler.stickingMode = .touchOnEdge
        default:
            helper.scrollViewHandler.stickingMode = .touchOnEdgeForOpen
        }
        if invertedConstant {
            helper.scrollViewHandler.direction = .forward
        } else {
            helper.scrollViewHandler.direction = .backward
        }
        
        panGesture = UIPanGestureRecognizer(target: helper.panGestureHandler, action: #selector(DrawerPanGestureHandler.handleDrawerPanGesture))
        drawerView.addGestureRecognizer(panGesture)
        panGesture.delegate = helper.panGestureHandler
        view.bringSubviewToFront(drawerView)
        
        helper.closeDrawer()
    }
    
}

extension ViewController: DrawerHelperDelegate {
    
    func drawerHelper(_ drawerHelper: DrawerHelper, didChangeTransitionProgress progress: Float) {
        darkView.alpha = CGFloat(progress) * 0.7
    }
}
