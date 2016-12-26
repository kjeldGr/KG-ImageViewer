//
//  DrawerControllerRouter.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit
import DrawerController

final class DrawerControllerRouter {
    
    // MARK: - Private
    
    private let menuWidth = CGFloat(240)
    private let window: UIWindow
    private var drawerController: DrawerController!
    
    private func setupDrawerController() {
        drawerController = DrawerController()
        drawerController.setMaximumLeftDrawerWidth(menuWidth, animated: false, completion: nil)
        drawerController.openDrawerGestureModeMask = OpenDrawerGestureMode.BezelPanningCenterView
        drawerController.closeDrawerGestureModeMask = [CloseDrawerGestureMode.PanningCenterView, CloseDrawerGestureMode.TapCenterView]
    }
    
    private func createStatusBarView() {
        let statusBarView = UIView()
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.backgroundColor = UIColor.mainColor
        drawerController.view.addSubview(statusBarView)
        drawerController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[statusBarView]|", options: .alignmentMask, metrics: nil, views: ["statusBarView": statusBarView]))
        drawerController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[statusBarView(==statusBarHeight)]", options: .alignmentMask, metrics: ["statusBarHeight": 20.0], views: ["statusBarView": statusBarView]))
    }
    
    // MARK: - Public
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        setupDrawerController()
        if Setting.showedIntro.isTrue() {
            let imageViewerRouter = ImageViewerRouter(drawerController: drawerController)
            imageViewerRouter.start()
        } else {
            let onboardingRouter = OnboardingRouter(drawerController: drawerController)
            onboardingRouter.start()
        }
        let settingsRouter = SettingsRouter(drawerController: drawerController)
        settingsRouter.start()
        
        createStatusBarView()
        window.rootViewController = drawerController
    }
    
}
