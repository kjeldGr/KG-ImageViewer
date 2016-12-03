//
//  UIButtonExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UIButton {
    
    var localizedTitleForNormal: String {
        set (key) {
            setTitle(key.localize(), for: .normal)
        }
        get {
            return title(for: .normal)!
        }
    }
    
    var localizedTitleForHighlighted: String {
        set (key) {
            setTitle(key.localize(), for: .highlighted)
        }
        get {
            return title(for: .highlighted)!
        }
    }
    
    var localizedTitleForSelected: String {
        set (key) {
            setTitle(key.localize(), for: .selected)
        }
        get {
            return title(for: .highlighted)!
        }
    }
    
}
