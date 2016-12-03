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
    case iPhone4, iPhone5, iPhone6, iPhone6Plus, iPad, unknown
}

open class Helper: NSObject {
    
    class func deviceType() -> DeviceType {
        let mainscreenBounds: CGRect = UIScreen.main.bounds
        
        if mainscreenBounds.height == 480 {
            return .iPhone4
        } else if mainscreenBounds.height == 568 {
            return .iPhone5
        } else if mainscreenBounds.height == 667 {
            return .iPhone6
        } else if mainscreenBounds.height == 736 {
            return .iPhone6Plus
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            return .iPad
        }
        return .unknown
    }
    
}
