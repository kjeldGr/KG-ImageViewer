//
//  UIStoryboardExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    func viewController(withViewType viewType: View) -> UIViewController {
        return instantiateViewController(withIdentifier: viewType.rawValue)
    }
    
}
