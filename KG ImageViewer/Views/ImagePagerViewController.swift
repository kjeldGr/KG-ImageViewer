//
//  ImagePagerViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit

class ImagePagerViewController: KGViewController {
    
    var pageViewController: UIPageViewController!
    var images: [ImageData]!
    var currentIndex = 0
    var transitionIndex = 0
    var transitionTitle: String!
    
    override func viewDidLoad() {
        let imageData = images[currentIndex]
        title = imageData.name
        
        super.viewDidLoad()
        
        let downloadButton = UIImage(named:"Download")!.navigationBarButtonWithAction({ (sender) -> Void in
            self.downloadImage()
        })
        navigationItem.setRightBarButtonItem(downloadButton, animated: false)
        
        let firstViewController = imageDetailViewControllerForIndex(currentIndex)!
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([firstViewController], direction: .Forward, animated: false, completion: nil)
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageView]|", options: .AlignmentMask, metrics: nil, views: ["pageView": pageViewController.view]) +
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageView]|", options: .AlignmentMask, metrics: nil, views: ["pageView": pageViewController.view]))
    }
    
    func downloadImage() {
        let currentController = pageViewController.viewControllers?.first as! ImageDetailViewController
        if currentController.detailImage != nil {
            UIImageWriteToSavedPhotosAlbum(currentController.detailImage, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            return
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
        let alert = alertControllerWithTitle(NSLocalizedString("error_please_wait_title", comment: ""), andMessage: NSLocalizedString("error_not_downloaded_message", comment: ""), andStyle: .Alert, andActions: [okAction])
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>)       {
        let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
        var alert: UIAlertController!
        if error != nil {
            alert = alertControllerWithTitle(NSLocalizedString("error_saving_failed_title", comment: ""), andMessage: NSLocalizedString("error_saving_failed_message", comment: ""), andStyle: .Alert, andActions: [okAction])
        }else{
            alert = alertControllerWithTitle(NSLocalizedString("error_saved_title", comment: ""), andMessage: NSLocalizedString("error_saved_message", comment: ""), andStyle: .Alert, andActions: [okAction])
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension ImagePagerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK: - Page View Controller Methods
    
    func imageDetailViewControllerForIndex(index: Int) -> ImageDetailViewController? {
        if index < 0 || index >= images.count {
            return nil
        }
        let imageDetailView = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailView") as! ImageDetailViewController
        imageDetailView.imageData = images[index]
        return imageDetailView
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return imageDetailViewControllerForIndex(currentIndex-1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return imageDetailViewControllerForIndex(currentIndex+1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let detailViewController = pendingViewControllers.first as? ImageDetailViewController {
            let imageData = detailViewController.imageData
            transitionIndex = images.indexOf(imageData)!
            transitionTitle = imageData.name
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (finished && completed) {
            currentIndex = transitionIndex
            updateTitle(transitionTitle)
        }
    }
    
}
