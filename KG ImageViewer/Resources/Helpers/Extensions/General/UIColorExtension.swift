//
//  UIColorExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: (CGFloat(((hex & 0xFF0000) >> 16)))/255.0,
                  green: (CGFloat(((hex & 0xFF00) >> 8)))/255.0,
                  blue: (CGFloat((hex & 0xFF)))/255.0,
                  alpha: alpha)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    
}
