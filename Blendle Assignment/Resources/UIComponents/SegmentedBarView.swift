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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Helper.mainColor
        
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: Helper.defaultFontWith(.Light, size: 12)], forState: UIControlState.Normal)
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(window)
        
        layer.shadowOffset = CGSizeMake(0, 1.0/UIScreen.mainScreen().scale)
        layer.shadowRadius = 0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
    }

}
