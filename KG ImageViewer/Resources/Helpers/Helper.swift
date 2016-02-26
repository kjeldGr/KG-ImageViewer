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

enum DeviceType: Int {
    case iPhone4, iPhone5, iPhone6, iPhone6Plus, iPad, Unknown
}

public class Helper: NSObject {
    static let mainColor = UIColor(hex: 0x4DE8AA)
    
    class func deviceType() -> DeviceType {
        let mainscreenBounds: CGRect = UIScreen.mainScreen().bounds
        
        if CGRectGetHeight(mainscreenBounds) == 480 {
            return .iPhone4
        } else if CGRectGetHeight(mainscreenBounds) == 568 {
            return .iPhone5
        } else if CGRectGetHeight(mainscreenBounds) == 667 {
            return .iPhone6
        } else if CGRectGetHeight(mainscreenBounds) == 736 {
            return .iPhone6Plus
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            return .iPad
        }
        return .Unknown
    }
    
}
