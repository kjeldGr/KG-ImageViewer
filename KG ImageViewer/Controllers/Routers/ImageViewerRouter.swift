//
//  ImageViewerRouter.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import DrawerController

final class ImageViewerRouter: DrawerControllerDescendantRouter<UINavigationController> {
    
    override func setupFirstViewController() -> UINavigationController {
        guard let photoGridViewController = storyboard.viewController(withViewType: .photoGrid) as? PhotoGridViewController else {
            assert(false, "The first UIViewController for ImageViewerRouter should be of type \"\(PhotoGridViewController.self)\"")
        }
        return UINavigationController(rootViewController: photoGridViewController)
    }
    
}
