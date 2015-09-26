//
//  Helper.swift
//  Scaffold Default
//
//  Created by Kjeld Groot on 07/08/15.
//  Copyright (c) 2015 Label A. All rights reserved.
//

import UIKit

/*
    Use this class to create public functions you want to use through the whole app
*/

enum FontType: String {
    case Bold = "Bold"
    case BoldItalic = "BoldItalic"
    case Semibold = "Semibold"
    case Italic = "RegularIt"
    case Light = "Light"
    case LightItalic = "LightIt"
    case Regular = "Regular"
}

enum DeviceType: Int {
    case iPhone4, iPhone5, iPhone6, iPhone6Plus, iPad, Unknown
}

public class Helper: NSObject {
   
    static let mainColor = Helper.colorFromHex(0xff6255)
    
    class func colorFromHex(hexValue: Int) -> UIColor {
        return UIColor(red: (CGFloat(((hexValue & 0xFF0000) >> 16)))/255.0,
            green: (CGFloat(((hexValue & 0xFF00) >> 8)))/255.0,
            blue: (CGFloat((hexValue & 0xFF)))/255.0,
            alpha: 1.0)
    }
    
    class func defaultFontWith(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-" + type.rawValue, size: size)!
    }
    
    class func deviceType() -> DeviceType {
        let mainscreenBounds: CGRect = UIScreen.mainScreen().bounds
        
        if CGRectGetHeight(mainscreenBounds) == 480 {
            return DeviceType.iPhone4
        } else if CGRectGetHeight(mainscreenBounds) == 568 {
            return DeviceType.iPhone5
        } else if CGRectGetHeight(mainscreenBounds) == 667 {
            return DeviceType.iPhone6
        } else if CGRectGetHeight(mainscreenBounds) == 736 {
            return DeviceType.iPhone6Plus
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            return DeviceType.iPad
        }
        return DeviceType.Unknown
    }
    
}
