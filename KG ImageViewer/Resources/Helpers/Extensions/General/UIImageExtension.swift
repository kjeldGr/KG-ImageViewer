//
//  UIImageExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit
import EZSwiftExtensions

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
