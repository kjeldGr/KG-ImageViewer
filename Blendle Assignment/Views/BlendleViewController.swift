//
//  BlendleViewController.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 25-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import DrawerController

extension UIView {
    
    public class var nameOfClass: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
    
    var loadFromNib: AnyObject? {
        let nibName = self.nameOfClass
        let elements = NSBundle.mainBundle().loadNibNamed(nibName, owner: nil, options: nil)
        
        for anObject in elements {
            if anObject.isKindOfClass(self.dynamicType) {
                return anObject
            }
        }
        
        return nil
    }
    
}

extension UISegmentedControl {
    
    func setLocalizedTitles(titles: [String]) {
        for title in titles {
            self.setTitle(NSLocalizedString(title, comment: ""), forSegmentAtIndex: titles.indexOf(title)!)
        }
    }
}

extension UIColor {
    
    func imageWithSize(size: CGSize) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

class BlendleViewController: UIViewController {
    
    var loading = false
    var appLoader: Loader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        setupNavigationBar()
        
        let completionHandler:(DrawerController, UIGestureRecognizer) -> Void = {
            (drawerController: DrawerController, gestureRecognizer: UIGestureRecognizer) -> Void in
            if drawerController.openSide == .Right {
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            } else {
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            }
        }
        evo_drawerController?.gestureCompletionBlock = completionHandler
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.translucent = false
        
        navigationController?.navigationBar.barTintColor = Helper.mainColor
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        updateTitle(title!)
    }
    
    func updateTitle(title: String) {
        let titleLabel = UILabel()
        titleLabel.font = Helper.defaultFontWith(.Regular, size: 24)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        titleLabel.sizeToFit()
    }
    
    func toggleMenu() {
        if evo_drawerController?.openSide == .Right {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            evo_drawerController?.openDrawerSide(.Right, animated: true, completion: nil)
        }
    }
    
    func closedDrawerController(drawerController: DrawerController, gestureRecognizer: UIGestureRecognizer) {
        
    }
    
    func alertControllerWithTitle(title: String, andMessage message: String, andStyle style: UIAlertControllerStyle, andActions actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        return alertController
    }
    
    func startLoading() {
        if !loading {
            loading = true
            
            if appLoader == nil {
                appLoader = Loader().loadFromNib as! Loader
                appLoader.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(appLoader)
                
                appLoader.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self(==140)]", options: .AlignmentMask, metrics: nil, views: ["self": appLoader]))
                appLoader.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self(==140)]", options: .AlignmentMask, metrics: nil, views: ["self": appLoader]))
                view.addConstraint(NSLayoutConstraint(item: appLoader, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: appLoader, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
            }
            appLoader.startAnimating()
            appLoader.hidden = false
        }
    }
    
    func stopLoading() {
        loading = false
        appLoader.hidden = true
        appLoader.stopAnimating()
    }
    
}
