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
    case photoGrid = "PhotoGridNavigationView"
    case intro = "IntroView"
    case filter = "FilterView"
    case imagePager = "ImagePagerView"
    case imageDetail = "ImageDetailView"
    case authentication = "AuthenticationView"
}

enum Segue: String {
    case showImage = "ShowImage"
}

// MARK: - Menu View Controller Protocol

protocol MenuViewController {
    func toggleMenu()
    func makeMenuViewController()
}

extension MenuViewController where Self: KGViewController {
    
    func makeMenuViewController() {
        navigationItem.setRightBarButton(UIImage(named: "Filter")!.navigationBarButton(action: { [unowned self] (sender) -> Void in
            self.toggleMenu()
        }), animated: false)
    }
    
    func toggleMenu() {
        if evo_drawerController?.openSide == .right {
            evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        } else {
            evo_drawerController?.openDrawerSide(.right, animated: true, completion: nil)
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
    var appLoader: Loader = Loader.loadFromNib()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        setupNavigationBar()
        
        if let menuViewController = self as? MenuViewController {
            menuViewController.makeMenuViewController()
        }
    }
    
    deinit {
        stopLoading()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.barTintColor = UIColor.mainColor
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        updateTitle(title)
    }
    
    func updateTitle(_ title: String?) {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.font(withType: .Regular, size: .heading3)
        titleLabel.textColor = UIColor.white
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        titleLabel.sizeToFit()
    }
    
}

extension KGViewController: AppLoader {
    
    func startLoading() {
        if loading {
            return
        }
        loading = true
        
        if !appLoader.isDescendant(of: view) {
            appLoader.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(appLoader)
            
            appLoader.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[appLoader(==140)]", options: .alignmentMask, metrics: nil, views: ["appLoader": appLoader]) + NSLayoutConstraint.constraints(withVisualFormat: "V:[appLoader(==140)]", options: .alignmentMask, metrics: nil, views: ["appLoader": appLoader]))
            appLoader.snp.makeConstraints({ (make) -> Void in
                make.centerX.equalTo(view)
                make.centerY.equalTo(view)
            })
        }
        appLoader.animating = true
        appLoader.isHidden = false
    }
    
    func stopLoading() {
        loading = false
        appLoader.isHidden = true
        appLoader.animating = false
    }
    
}
