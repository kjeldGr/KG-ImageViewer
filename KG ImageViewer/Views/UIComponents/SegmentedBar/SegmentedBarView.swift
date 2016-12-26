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
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: window)
        
        backgroundColor = UIColor.mainColor
        
        layer.shadowOffset = CGSize(width: 0, height: 1.0/UIScreen.main.scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.font(withType: .Light, size: .paragraph3)!], for: UIControlState())
        
        searchBar.setBackgroundImage(UIImage.image(withColor: UIColor.mainColor, size: CGSize(width: 1, height: 1)), for: .top, barMetrics: UIBarMetrics.default)
        
        let textfieldFont = UIFont.font(withType: .Regular, size: .paragraph3)
        if #available(iOS 9.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = textfieldFont
        } else {
            for textField in searchBar.subviews where textField.isKind(of: UITextField.self) {
                (textField as! UITextField).font = textfieldFont
            }
        }
    }
    
    func animateSearchBar(_ open: Bool) {
        let animationSpeed = 0.15
        showingSearchBar = open
        let heightConstraint = constraints.filter() { $0.firstAttribute == .height }.first!
        if open {
            UIView.animate(withDuration: animationSpeed, animations: { [unowned self] () -> Void in
                heightConstraint.constant += 44
                self.layoutIfNeeded()
                }, completion: { [unowned self] (finished) -> Void in
                    UIView.animate(withDuration: animationSpeed, animations: { () -> Void in
                        self.searchBar.isHidden = false
                        self.searchBar.alpha = 1
                        }, completion: { [unowned self] (finished) -> Void in
                            self.searchBar.becomeFirstResponder()
                        })
                })
            return
        }
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: animationSpeed, animations: { [unowned self] () -> Void in
            self.searchBar.alpha = 0
            }, completion: { [unowned self] (finished) -> Void in
                self.searchBar.isHidden = true
                self.searchBar.text = ""
                UIView.animate(withDuration: animationSpeed, animations: { [unowned self] () -> Void in
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
