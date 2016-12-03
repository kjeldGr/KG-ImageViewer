//
//  UISegmentedControlExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    func setLocalizedTitles(_ titles: [String]) {
        for title in titles {
            setTitle(title.localize(), forSegmentAt: titles.index(of: title)!)
        }
    }
    
}
