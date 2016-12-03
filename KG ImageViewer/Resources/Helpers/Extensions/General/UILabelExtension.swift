//
//  UILabelExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UILabel {
    
    var localizedText: String {
        set (key) {
            text = key.localize()
        }
        get {
            return text!
        }
    }
    
}
