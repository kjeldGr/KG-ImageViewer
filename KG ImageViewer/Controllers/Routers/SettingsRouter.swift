//
//  SettingsRouter.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import DrawerController

final class SettingsRouter: DrawerControllerDescendantRouter<FilterViewController> {
    
    override var drawerControllerSide: DrawerSide {
        return .right
    }
    
    override func setupFirstViewController() -> FilterViewController {
        guard let filterViewController = storyboard.viewController(withViewType: .filter) as? FilterViewController else {
            assert(false, "The first UIViewController for SettingsRouter should be of type \"\(FilterViewController.self)\"")
        }
        return filterViewController
    }
    
}
