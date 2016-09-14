//
//  SegmentedBarView.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit

class SegmentedBarView: UIView {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    var showingSearchBar = false
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(window)
        
        backgroundColor = Helper.mainColor
        
        layer.shadowOffset = CGSizeMake(0, 1.0/UIScreen.mainScreen().scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.font(withType: .Light, size: .Paragraph3)!], forState: UIControlState.Normal)
        
        searchBar.setBackgroundImage(UIImage.imageWithColor(Helper.mainColor, size: CGSizeMake(1, 1)), forBarPosition: .Top, barMetrics: UIBarMetrics.Default)
        
        let textfieldFont = UIFont.font(withType: .Regular, size: .Paragraph3)
        if #available(iOS 9.0, *) {
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).font = textfieldFont
        } else {
            for textField in searchBar.subviews where textField.isKindOfClass(UITextField) {
                (textField as! UITextField).font = textfieldFont
            }
        }
    }
    
    func animateSearchBar(open: Bool) {
        let animationSpeed = 0.15
        showingSearchBar = open
        let heightConstraint = constraints.filter() { $0.firstAttribute == .Height }.first!
        if open {
            UIView.animateWithDuration(animationSpeed, animations: { [unowned self] () -> Void in
                heightConstraint.constant += 44
                self.layoutIfNeeded()
                }, completion: { [unowned self] (finished) -> Void in
                    UIView.animateWithDuration(animationSpeed, animations: { () -> Void in
                        self.searchBar.hidden = false
                        self.searchBar.alpha = 1
                        }, completion: { [unowned self] (finished) -> Void in
                            self.searchBar.becomeFirstResponder()
                        })
                })
            return
        }
        searchBar.resignFirstResponder()
        UIView.animateWithDuration(animationSpeed, animations: { [unowned self] () -> Void in
            self.searchBar.alpha = 0
            }, completion: { [unowned self] (finished) -> Void in
                self.searchBar.hidden = true
                self.searchBar.text = ""
                UIView.animateWithDuration(animationSpeed, animations: { [unowned self] () -> Void in
                    heightConstraint.constant -= 44
                    self.layoutIfNeeded()
                    })
            })
    }
    
    func showSearchBar() {
        animateSearchBar(true)
    }
    
    func closeSearchBar() {
        animateSearchBar(false)
    }
}
