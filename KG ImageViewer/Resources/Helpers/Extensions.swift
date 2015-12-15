//
//  Extensions.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 14-12-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

// MARK: - UI Elements

extension UIView {
    
    public class var nameOfClass: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
    
    var loadFromNib: AnyObject? {
        let nibName = nameOfClass
        let elements = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)
        
        for anObject in elements {
            if anObject.isKindOfClass(self.dynamicType) {
                return anObject
            }
        }
        
        return nil
    }
    
}

extension UILabel {
    var localizedText: String {
        set (key) {
            text = NSLocalizedString(key, comment: "")
        }
        get {
            return text!
        }
    }
}

extension UIButton {
    var localizedTitleForNormal: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), forState: .Normal)
        }
        get {
            return titleForState(.Normal)!
        }
    }
    
    var localizedTitleForHighlighted: String {
        set (key) {
            setTitle(NSLocalizedString(key, comment: ""), forState: .Highlighted)
        }
        get {
            return titleForState(.Highlighted)!
        }
    }
}

extension UISegmentedControl {
    
    func setLocalizedTitles(titles: [String]) {
        for title in titles {
            setTitle(NSLocalizedString(title, comment: ""), forSegmentAtIndex: titles.indexOf(title)!)
        }
    }
}

extension UIImage {
    
    func navigationBarButtonWithAction(action: BlockButtonAction) -> UIBarButtonItem {
        let button = BlockButton(frame: CGRect(x: 0, y: 0, w: size.width, h: size.height), action: action)
        button.setImage(self, forState: .Normal)
        let barButton: UIBarButtonItem = UIBarButtonItem(customView: button)
        return barButton
    }
    
}

extension UIColor {
    
    func imageWithSize(size: CGSize) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

// MARK: - Numeric types

extension Int {
    
    func color() -> UIColor {
        return UIColor(red: (CGFloat(((self & 0xFF0000) >> 16)))/255.0,
            green: (CGFloat(((self & 0xFF00) >> 8)))/255.0,
            blue: (CGFloat((self & 0xFF)))/255.0,
            alpha: 1.0)
    }
    
}

// MARK: - Object Types

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key,value) in other {
            updateValue(value, forKey:key)
        }
    }
}