//
//  PhotoGridViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 25-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Spring

enum Category: String {
    case Popular = "popular"
    case HighestRating = "highest_rated"
    case Editors = "editors"
    case Upcoming = "upcoming"
}

class PhotoGridViewController: KGViewController, MenuViewController {
    
    @IBOutlet weak var splashView: SpringView!
    @IBOutlet weak var logoImage: SpringImageView!
    @IBOutlet weak var categorySegmentedBarView: SegmentedBarView!
    @IBOutlet weak var disableView: UIView!
    
    private var currentCategory: Category = .Popular
    private var currentPage = 1
    private var searching = false
    private var searchTerm: String!
    private var images = [ImageData]()
    
    // Collection View properties
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let imageCellIdentifier = "KGImageCell"
    let sectionInset: CGFloat = 5
    let cellSpacing: CGFloat = 2
    let cellsPerRow = 4
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        title = NSLocalizedString("view_photo_grid_title", comment: "")
        
        super.viewDidLoad()
        
        imageCollectionView.accessibilityLabel = "PhotoGridCollectionView"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhotoGridViewController.reloadImages), name: Setting.ShowNSFW.rawValue, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage.imageWithColor(.clearColor(), size: CGSizeMake(1, 1))
        navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(Helper.mainColor, size: CGSizeMake(1, 1)), forBarMetrics: UIBarMetrics.Default)
        
        let searchBarButton = UIImage(named: "Search")!.navigationBarButtonWithAction { [unowned self] (sender) -> Void in
            self.toggleSearchBar()
        }
        navigationItem.setRightBarButtonItems([navigationItem.rightBarButtonItem!, searchBarButton], animated: false)
        
        categorySegmentedBarView.segmentedControl.setLocalizedTitles(["photo_grid_category_popular", "photo_grid_category_highest_rating", "photo_grid_category_editors", "photo_grid_category_upcoming"])
        
        categorySegmentedBarView.searchBar.delegate = self
        
        layoutCollectionView()
        
        imageCollectionView!.registerClass(KGImageCell.classForCoder(), forCellWithReuseIdentifier: imageCellIdentifier)
        
        refreshControl.backgroundColor = Helper.mainColor
        refreshControl.tintColor = UIColor.whiteColor()
        imageCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(PhotoGridViewController.reloadImages), forControlEvents: UIControlEvents.ValueChanged)
        
        updateImages()
        
        appLoader.hidden = true
        logoImage.animate()
        splashView.animateNext { [unowned self] () -> () in
            if self.loading {
                self.appLoader.hidden = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImage" {
            navigationController!.navigationBar.topItem!.title = NSLocalizedString("text_back", comment: "");
            let detailViewController = segue.destinationViewController as! ImagePagerViewController
            detailViewController.images = images
            detailViewController.currentIndex = sender as! Int
        }
    }
    
    // MARK: - Load Images methods
    
    func reloadImages() {
        images.removeAll()
        currentPage = 1
        
        imageCollectionView.reloadData()
        
        updateImages()
    }
    
    override func stopLoading() {
        super.stopLoading()
        refreshControl.endRefreshing()
    }
    
    func updateImages() {
        if loading {
            return
        }
        
        startLoading()
        
        var request: URLRequestConvertible!
        if searching {
            request = API.Router.searchImages(["page": currentPage, "feature": currentCategory.rawValue, "term": searchTerm])
        } else {
            request = API.Router.getImages(["page": currentPage, "feature": currentCategory.rawValue])
        }
        
        Alamofire.request(request).validate()
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                switch response.result {
                case .Success(let data):
                    let resultData = JSON(data)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let lastItem = strongSelf.images.count
                        
                        let showNSFW = NSUserDefaults.standardUserDefaults().boolForKey(Setting.ShowNSFW.rawValue)
                        let resultImages = resultData["photos"].arrayValue
                        strongSelf.addImages(resultImages, showNSFW: showNSFW)
                        
                        let indexPaths = (lastItem..<strongSelf.images.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            strongSelf.insertImagesInCollectionView(indexPaths)
                        }
                    }
                case .Failure(_):
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default, handler: { (alertAction) in
                        strongSelf.updateImages()
                    })
                    
                    let alertController = strongSelf.alertControllerWithTitle(NSLocalizedString("error_loading_images_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    strongSelf.presentViewController(alertController, animated: true, completion: nil)
                    
                    strongSelf.stopLoading()
                }
            }
    }
    
    func addImages(resultImages: [JSON], showNSFW: Bool) {
        images += resultImages.flatMap {
            if !showNSFW && $0.dictionaryValue["nsfw"]!.boolValue == true {
                return nil
            }
            return ImageData(data: $0.dictionaryValue)
        }
    }
    
    func insertImagesInCollectionView(indexPaths: [NSIndexPath]) {
        if images.count < indexPaths.count {
            return
        }
        imageCollectionView!.insertItemsAtIndexPaths(indexPaths)
        currentPage += 1
        stopLoading()
    }
    
    @IBAction func didSelectCategory(sender: AnyObject) {
        let segmentedControl = sender as! UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            currentCategory = .HighestRating
        case 2:
            currentCategory = .Editors
        case 3:
            currentCategory = .Upcoming
        default:
            currentCategory = .Popular
        }
        
        reloadImages()
    }
    
}

extension PhotoGridViewController: UIScrollViewDelegate {
    
    // MARK: - Scroll View Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            updateImages()
        }
    }
    
}

extension PhotoGridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func layoutCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        var itemSize = CGRectGetWidth(UIScreen.mainScreen().bounds)/CGFloat(cellsPerRow)
        itemSize -= (sectionInset*2.0)-(CGFloat(cellsPerRow-1)*cellSpacing)
        
        flowLayout.itemSize = CGSizeMake(itemSize, itemSize)
        flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        
        imageCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageCellIdentifier, forIndexPath: indexPath) as! KGImageCell
        
        let imageURL = images[indexPath.item].url
        cell.request?.cancel()
        
        if let image = CacheData.sharedInstance.thumbnailCache.objectForKey(imageURL) as? UIImage {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            cell.request = Alamofire.request(Alamofire.Method.GET, imageURL)
                .validate(contentType: ["image/*"])
                .responseData { response -> Void in
                    switch response.result {
                    case .Success(let data):
                        let image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
                        CacheData.sharedInstance.thumbnailCache.setObject(image!, forKey: response.request!.URLString)
                        cell.imageView.image = image
                    case .Failure(_):
                        break
                    }
                }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowImage", sender: indexPath.item)
    }
    
}

extension PhotoGridViewController: UISearchBarDelegate {
    
    // MARK: - Search Bar Methods
    
    @IBAction func didTapDisableView(sender: AnyObject) {
        if categorySegmentedBarView.searchBar.text! == "" {
            closeSearchBar()
        }
    }
    
    func toggleSearchBar() {
        if categorySegmentedBarView.showingSearchBar {
            closeSearchBar()
        } else {
            categorySegmentedBarView.showSearchBar()
        }
    }
    
    func closeSearchBar() {
        disableView.hidden = true
        
        categorySegmentedBarView.closeSearchBar()
        categorySegmentedBarView.searchBar.resignFirstResponder()
        
        if searching {
            searching = false
            searchTerm = ""
            
            reloadImages()
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        disableView.hidden = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        disableView.hidden = true
        
        searching = true
        searchTerm = searchBar.text!
        
        searchBar.resignFirstResponder()
        
        reloadImages()
    }
    
}