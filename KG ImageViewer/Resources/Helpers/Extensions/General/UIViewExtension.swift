//
//  UIViewExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UIView {
    
    public class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    class func loadFromNib<T>() -> T? {
        let nibName = nameOfClass
        let elements = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        
        for anObject in elements {
            if let view = anObject as? T {
                return view
            }
        }
        
        return nil
    }
    
    func subviewsOfType<T>() -> [T] where T: UIView {
        return subviews.filter({ (view) -> Bool in
            return view.isKind(of: T.self)
        }) as! [T]
    }
    
}
