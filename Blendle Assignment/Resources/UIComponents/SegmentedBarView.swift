//
//  SegmentedBarView.swift
//  Blendle Assignment
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
        
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: Helper.defaultFontWith(.Light, size: 12)], forState: UIControlState.Normal)
        
        searchBar.setBackgroundImage(Helper.mainColor.imageWithSize(CGSizeMake(1, 1)), forBarPosition: .Top, barMetrics: UIBarMetrics.Default)
        
        let textfieldFont = Helper.defaultFontWith(.Regular, size: 15)
        if #available(iOS 9.0, *) {
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).font = textfieldFont
        } else {
            for subview in searchBar.subviews {
                if subview.isKindOfClass(UITextField) {
                    let textfield = subview as! UITextField
                    textfield.font = textfieldFont
                    break
                }
            }
        }
    }
    
    func animateSearchBar(open: Bool) {
        self.showingSearchBar = open
        let heightConstraint = constraints.filter() { $0.firstAttribute == .Height }[0]
        if open {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                heightConstraint.constant += 44
                self.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        self.searchBar.hidden = false
                        self.searchBar.alpha = 1
                        }, completion: { (finished) -> Void in
                            self.searchBar.becomeFirstResponder()
                    })
            })
        } else {
            self.searchBar.resignFirstResponder()
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.searchBar.alpha = 0
                }, completion: { (finished) -> Void in
                    self.searchBar.hidden = true
                    self.searchBar.text = ""
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        heightConstraint.constant -= 44
                        self.layoutIfNeeded()
                    })
            })
        }
    }
    
    func showSearchBar() {
        animateSearchBar(true)
    }
    
    func closeSearchBar() {
        animateSearchBar(false)
    }
}