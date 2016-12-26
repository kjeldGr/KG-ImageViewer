//
//  DrawerControllerDescendantRouter.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import DrawerController

class DrawerControllerDescendantRouter<FirstViewController: UIViewController> {
    
    // MARK: - Private
    
    private let drawerController: DrawerController
    private var descendantViewController: FirstViewController!
    
    // MARK: - Public
    
    var storyboard: UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    var drawerControllerSide: DrawerSide { return .none }
    
    func setupFirstViewController() -> FirstViewController {
        assert(false, "This function should be overridden in subclass")
    }
    
    init(drawerController: DrawerController) {
        self.drawerController = drawerController
    }
    
    func start() {
        descendantViewController = setupFirstViewController()
        switch drawerControllerSide {
        case .right:
            drawerController.rightDrawerViewController = descendantViewController
        case .left:
            drawerController.leftDrawerViewController = descendantViewController
        default:
            drawerController.centerViewController = descendantViewController
        }
    }
    
}
