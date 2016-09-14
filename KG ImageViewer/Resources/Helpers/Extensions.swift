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

// Mark: - String

extension String {
    
    func localize(table: String? = nil) -> String {
        return NSLocalizedString(self, tableName: table, comment: "")
    }
    
}

// Mark: - Objects

extension NSObject {
    
    func currentAppDelegate() -> AppDelegate? {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            return appDelegate
        }
        return nil
    }
    
    func addToDefaults(value: AnyObject, key: String) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getObjectFromDefaults(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
}

extension NSObject {
    
    func DLog(message:String, function:String = #function) {
        // Before you can use this please make sure you added the "-DDEBUG" flag to: Swift Compiler - Custom Flags->Other
        #if DEBUG
            print("\(self.dynamicType) - \(function): \(message)")
        #endif
    }
    
}

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key,value) in other {
            updateValue(value, forKey:key)
        }
    }
    
}

extension UIStoryboard {
    
    func viewController(withViewType viewType: View) -> UIViewController {
        return instantiateViewControllerWithIdentifier(viewType.rawValue)
    }
    
}

// MARK: - UI View Elements

extension UIView {
    
    public class var nameOfClass: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    class func loadFromNib() -> UIView? {
        let nibName = nameOfClass
        let elements = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)
        
        for anObject in elements where anObject.isKindOfClass(UIView) {
            return anObject as? UIView
        }
        
        return nil
    }
    
}

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

extension UIButton {
    
    var localizedTitleForNormal: String {
        set (key) {
            setTitle(key.localize(), forState: .Normal)
        }
        get {
            return titleForState(.Normal)!
        }
    }
    
    var localizedTitleForHighlighted: String {
        set (key) {
            setTitle(key.localize(), forState: .Highlighted)
        }
        get {
            return titleForState(.Highlighted)!
        }
    }
    
}

extension UISegmentedControl {
    
    func setLocalizedTitles(titles: [String]) {
        for title in titles {
            setTitle(title.localize(), forSegmentAtIndex: titles.indexOf(title)!)
        }
    }
    
}

extension UIImage {
    
    func navigationBarButtonWithAction(highlightedImage: UIImage? = nil, setSelected: Bool = false, action: BlockButtonAction) -> UIBarButtonItem {
        let button = BlockButton(frame: CGRect(x: 0, y: 0, w: size.width, h: size.height), action: action)
        button.setImage(self, forState: .Normal)
        button.setImage(highlightedImage, forState: .Highlighted)
        button.setImage(highlightedImage, forState: .Selected)
        button.selected = setSelected
        let barButton: UIBarButtonItem = UIBarButtonItem(customView: button)
        return barButton
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

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

enum FontSize: CGFloat {
    case Paragraph1 = 7.0
    case Paragraph2 = 11.0
    case Paragraph3 = 12.0
    case Paragraph4 = 15.0
    case Paragraph5 = 16.0
    case Paragraph6 = 18.0
    case Heading1 = 20.0
    case Heading2 = 22.0
    case Heading3 = 24.0
    case Heading4 = 26.0
}

extension UIFont {
    
    class func font(withType type: FontType, size: FontSize) -> UIFont? {
        return UIFont(familyName: .ProximaNova, fontType: type, size: size.rawValue)
    }
    
    enum FontFamilyName: String {
        case HelveticaNeue = "HelveticaNeue"
        case ProximaNova = "ProximaNova"
    }
    
    enum FontType: String {
        case Bold = "-Bold"
        case BoldItalic = "-BoldItalic"
        case Semibold = "-Semibold"
        case Italic = "-RegularIt"
        case Light = "-Light"
        case LightItalic = "-LightIt"
        case Regular = "-Regular"
    }
    
    convenience init? (familyName: FontFamilyName, fontType: FontType, size: CGFloat) {
        let name = familyName.rawValue+fontType.rawValue
        self.init(name: name, size: size)
    }
    
}