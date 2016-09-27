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
    
    func localize(fromTable table: String? = nil) -> String {
        return NSLocalizedString(self, tableName: table, comment: "")
    }
    
}

// Mark: - Objects

extension NSObject {
    
    func currentAppDelegate() -> AppDelegate? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate
        }
        return nil
    }
    
    func addObjectToDefaults(withValue value: AnyObject, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getObjectFromDefaults(withKey key: String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }
    
}

extension NSObject {
    
    func DLog(_ message:String, function:String = #function) {
        // Before you can use this please make sure you added the "-DDEBUG" flag to: Swift Compiler - Custom Flags->Other
        #if DEBUG
            print("\(type(of: self)) - \(function): \(message)")
        #endif
    }
    
}

extension Dictionary {
    mutating func update(_ other: Dictionary) {
        for (key,value) in other {
            updateValue(value, forKey:key)
        }
    }
    
}

extension UIStoryboard {
    
    func viewController(withViewType viewType: View) -> UIViewController {
        return instantiateViewController(withIdentifier: viewType.rawValue)
    }
    
}

// MARK: - UI View Elements

extension UIView {
    
    public class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    class func loadFromNib() -> UIView? {
        let nibName = nameOfClass
        let elements = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        
        for anObject in elements {
            if let view = anObject as? UIView {
                return view
            }
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
            setTitle(key.localize(), for: UIControlState())
        }
        get {
            return title(for: UIControlState())!
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
    
}

extension UISegmentedControl {
    
    func setLocalizedTitles(_ titles: [String]) {
        for title in titles {
            setTitle(title.localize(), forSegmentAt: titles.index(of: title)!)
        }
    }
    
}

extension UIImage {
    
    func navigationBarButton(withHighlightedImage highlightedImage: UIImage? = nil, setSelected: Bool = false, action: @escaping BlockButtonAction) -> UIBarButtonItem {
        let button = BlockButton(frame: CGRect(x: 0, y: 0, w: size.width, h: size.height), action: action)
        button.setImage(self, for: UIControlState())
        button.setImage(highlightedImage, for: .highlighted)
        button.setImage(highlightedImage, for: .selected)
        button.isSelected = setSelected
        let barButton: UIBarButtonItem = UIBarButtonItem(customView: button)
        return barButton
    }
    
    class func image(withColor color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
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
    case paragraph1 = 7.0
    case paragraph2 = 11.0
    case paragraph3 = 12.0
    case paragraph4 = 15.0
    case paragraph5 = 16.0
    case paragraph6 = 18.0
    case heading1 = 20.0
    case heading2 = 22.0
    case heading3 = 24.0
    case heading4 = 26.0
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
