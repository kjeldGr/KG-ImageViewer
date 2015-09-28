//
//  PhotoGridViewController.swift
//  Blendle Assignment
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

class PhotoGridViewController: BlendleViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var splashView: SpringView!
    @IBOutlet weak var blendleLogo: SpringImageView!
    @IBOutlet weak var categorySegmentedBarView: SegmentedBarView!
    @IBOutlet weak var disableView: UIView!
    
    private var currentCategory = Category.Popular
    private var currentPage = 1
    private var searching = false
    private var searchTerm: String!
    private var images: [ImageData] = Array()
    
    // Collection View properties
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let imageCellIdentifier = "BlendleImageCell"
    let loaderCellIdentifier = "BlendleLoaderCell"
    let sectionInset: CGFloat = 5
    let cellSpacing: CGFloat = 2
    let cellsPerRow = 4
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        title = NSLocalizedString("view_photo_grid_title", comment: "")
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadImages", name: Setting.ShowNSFW.rawValue, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIColor.clearColor().imageWithSize(CGSizeMake(1, 1))
        navigationController?.navigationBar.setBackgroundImage(Helper.mainColor.imageWithSize(CGSizeMake(1, 1)), forBarMetrics: UIBarMetrics.Default)
        
        let filterBarButton = navigationBarButtonWithIcon(UIImage(named: "Filter")!, action: "toggleMenu")
        let searchBarButton = navigationBarButtonWithIcon(UIImage(named: "Search")!, action: "toggleSearchBar")
        navigationItem.setRightBarButtonItems([filterBarButton, searchBarButton], animated: false)
        
        categorySegmentedBarView.segmentedControl.setLocalizedTitles(["photo_grid_category_popular", "photo_grid_category_highest_rating", "photo_grid_category_editors", "photo_grid_category_upcoming"])
        
        categorySegmentedBarView.searchBar.delegate = self
        
        layoutCollectionView()
        
        imageCollectionView!.registerClass(BlendleImageCell.classForCoder(), forCellWithReuseIdentifier: imageCellIdentifier)
        imageCollectionView!.registerClass(BlendleImageLoaderCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loaderCellIdentifier)
        
        refreshControl.backgroundColor = Helper.mainColor
        refreshControl.tintColor = UIColor.whiteColor()
        imageCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "reloadImages", forControlEvents: UIControlEvents.ValueChanged)
        
        updateImages()
        
        appLoader.hidden = true
        blendleLogo.animate()
        splashView.animateNext { () -> () in
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
            .responseJSON(completionHandler: { (request, response, result) -> Void in
                switch result {
                case .Success(let data):
                    let resultData = JSON(data).dictionaryValue
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let showNSFW = NSUserDefaults.standardUserDefaults().boolForKey(Setting.ShowNSFW.rawValue)
                        
                        let resultImages = resultData["photos"]!.arrayValue
                        let lastItem = self.images.count
                        for image in resultImages {
                            if !showNSFW && image.dictionaryValue["nsfw"]!.boolValue == true {
                                continue
                            }
                            self.images.append(ImageData(data: image.dictionaryValue))
                        }
                        
                        let indexPaths = (lastItem..<self.images.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.images.count < indexPaths.count {
                                return
                            }
                            self.imageCollectionView!.insertItemsAtIndexPaths(indexPaths)
                            self.currentPage++
                            self.stopLoading()
                        }
                    }
                case Result.Failure(_, _):
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default) {
                        UIAlertAction in
                        
                    }
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default) {
                        UIAlertAction in
                        self.updateImages()
                    }
                    
                    let alertController = self.alertControllerWithTitle(NSLocalizedString("error_loading_images_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    self.stopLoading()
                }
            })
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
    
    // MARK: - Search Bar Methods
    
    @IBAction func didTapDisableView(sender: AnyObject) {
        if categorySegmentedBarView.searchBar.text?.length == 0 {
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
    
    // MARK: - Scroll View Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            updateImages()
        }
    }
    
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageCellIdentifier, forIndexPath: indexPath) as! BlendleImageCell
        
        let imageURL = images[indexPath.item].url
        cell.request?.cancel()
        
        if let image = CacheData.sharedInstance.thumbnailCache.objectForKey(imageURL) as? UIImage {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            cell.request = Alamofire.request(Alamofire.Method.GET, imageURL)
                .validate(contentType: ["image/*"])
                .responseData({ (request, response, result) -> Void in
                    switch result {
                    case .Success(let data):
                        let image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
                        CacheData.sharedInstance.thumbnailCache.setObject(image!, forKey: request!.URLString)
                        cell.imageView.image = image
                    case .Failure(_, _):
                        break
                    }
                })
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowImage", sender: indexPath.item)
    }
}
