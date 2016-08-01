//
//  KGViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 25-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import DrawerController
import EZSwiftExtensions

enum View: String {
    case PhotoGrid = "PhotoGridNavigationView"
    case Intro = "IntroView"
    case Filter = "FilterView"
}

// MARK: - Menu View Controller Protocol

protocol MenuViewController {
    func toggleMenu()
    func makeMenuViewController()
}

extension MenuViewController where Self: KGViewController {
    
    func makeMenuViewController() {
        navigationItem.setRightBarButtonItem(UIImage(named: "Filter")!.navigationBarButtonWithAction({ [unowned self] (sender) -> Void in
            self.toggleMenu()
        }), animated: false)
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
    
    func toggleMenu() {
        if evo_drawerController?.openSide == .Right {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            evo_drawerController?.openDrawerSide(.Right, animated: true, completion: nil)
        }
    }
    
}

// MARK: - App Loader Protocol

protocol AppLoader {
    var loading: Bool { get }
    var appLoader: Loader { get }
    func startLoading()
    func stopLoading()
}

// Main View Controller

class KGViewController: UIViewController {
    
    var loading = false
    var appLoader = Loader.loadFromNib() as! Loader
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        setupNavigationBar()
        
        if let menuViewController = self as? MenuViewController {
            menuViewController.makeMenuViewController()
        }
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
        titleLabel.font = UIFont(familyName: .ProximaNova, fontType: .Regular, size: 24)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        titleLabel.sizeToFit()
    }
    
    func alertControllerWithTitle(title: String, andMessage message: String, andStyle style: UIAlertControllerStyle, andActions actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        return alertController
    }
    
}

extension KGViewController: AppLoader {
    
    func startLoading() {
        if loading {
            return
        }
        loading = true
        
        if !appLoader.isDescendantOfView(view) {
            appLoader.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(appLoader)
            
            appLoader.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[appLoader(==140)]", options: .AlignmentMask, metrics: nil, views: ["appLoader": appLoader]) + NSLayoutConstraint.constraintsWithVisualFormat("V:[appLoader(==140)]", options: .AlignmentMask, metrics: nil, views: ["appLoader": appLoader]))
            appLoader.snp_makeConstraints(closure: { (make) -> Void in
                make.centerX.equalTo(view)
                make.centerY.equalTo(view)
            })
        }
        appLoader.animating = true
        appLoader.hidden = false
    }
    
    func stopLoading() {
        loading = false
        appLoader.hidden = true
        appLoader.animating = false
    }
    
}