//
//  UIViewControllerExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @discardableResult
    func showAlertController(withTitle title: String, andMessage message: String, andStyle style: UIAlertControllerStyle = .alert, andActions actions: [UIAlertAction], completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: completion)
        
        return alertController
    }
    
}
