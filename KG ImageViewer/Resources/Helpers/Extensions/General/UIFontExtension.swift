//
//  UIFontExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

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
