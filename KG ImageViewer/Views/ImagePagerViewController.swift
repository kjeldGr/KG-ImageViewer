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
        
        let downloadButton = UIImage(named:"Download")!.navigationBarButton(action: { [unowned self] (sender) -> Void in
            self.downloadImage()
        })
        
        let favoriteButton = UIImage(named:"Rating")!.navigationBarButton(withHighlightedImage: UIImage(named: "RatingHighlighted"), setSelected: imageData.isFavorite(), action: { [unowned self] (sender) -> Void in
            self.favoriteImage(sender)
        })
        navigationItem.setRightBarButtonItems([downloadButton, favoriteButton], animated: false)
        
        let firstViewController = imageDetailViewController(forIndex: currentIndex)!
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageView]|", options: .alignmentMask, metrics: nil, views: ["pageView": pageViewController.view]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[pageView]|", options: .alignmentMask, metrics: nil, views: ["pageView": pageViewController.view]))
    }
    
    lazy var currentController: ImageDetailViewController = {
        return self.pageViewController.viewControllers?.first as! ImageDetailViewController
    }()
    
    func downloadImage() {
        guard currentController.detailImage != nil else {
            let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
            let alert = alertController(withTitle: "error_please_wait_title".localize(), andMessage: "error_not_downloaded_message".localize(), andStyle: .alert, andActions: [okAction])
            present(alert, animated: true, completion: nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(currentController.detailImage, self, #selector(ImagePagerViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func favoriteImage(_ sender: AnyObject) {
        guard let favoriteButton = sender as? UIButton else { return }
        favoriteButton.isSelected = !favoriteButton.isSelected
        
        CoreDataManager.saveManagedObject(withEntityName: "ImageDataCoreData", values: currentController.imageData.valuesForCoreDataObject(), save: favoriteButton.isSelected)
        
        DLog("\(currentAppDelegate()!.managedObjectContext.insertedObjects))")
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer)       {
        let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
        var alert: UIAlertController!
        if error != nil {
            alert = alertController(withTitle: "error_saving_failed_title".localize(), andMessage: "error_saving_failed_message".localize(), andStyle: .alert, andActions: [okAction])
        }else{
            alert = alertController(withTitle: "error_saved_title".localize(), andMessage: "error_saved_message".localize(), andStyle: .alert, andActions: [okAction])
        }
        present(alert, animated: true, completion: nil)
    }
    
}

extension ImagePagerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK: - Page View Controller Methods
    
    func imageDetailViewController(forIndex index: Int) -> ImageDetailViewController? {
        if index < 0 || index >= images.count {
            return nil
        }
        let imageDetailView = storyboard?.viewController(withViewType: .ImageDetail) as! ImageDetailViewController
        imageDetailView.imageData = images[index]
        return imageDetailView
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return imageDetailViewController(forIndex: currentIndex-1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return imageDetailViewController(forIndex: currentIndex+1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let detailViewController = pendingViewControllers.first as? ImageDetailViewController {
            let imageData = detailViewController.imageData!
            transitionIndex = images.index(of: imageData)!
            transitionTitle = imageData.name
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (finished && completed) {
            currentIndex = transitionIndex
            updateTitle(transitionTitle)
        }
    }
    
}
