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
    case popular = "popular"
    case highestRating = "highest_rated"
    case upcoming = "upcoming"
    case favorites = "favorites"
}

class PhotoGridViewController: KGViewController, MenuViewController {
    
    @IBOutlet weak var splashView: SpringView!
    @IBOutlet weak var logoImage: SpringImageView!
    @IBOutlet weak var categorySegmentedBarView: SegmentedBarView!
    @IBOutlet weak var disableView: UIView!
    
    fileprivate var currentCategory: Category = .popular
    fileprivate var currentPage = 1
    fileprivate var searching = false
    fileprivate var searchTerm: String!
    fileprivate var currentIndex = 0
    
    // Collection View properties
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var imageDataSource: KGImageCollectionViewDataSource!
    let sectionInset: CGFloat = 5
    let cellSpacing: CGFloat = 2
    let cellsPerRow = 4
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        title = "view_photo_grid_title".localize()
        
        super.viewDidLoad()
        
        // Check for 3D touch availability
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: imageCollectionView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoGridViewController.reloadImages), name: NSNotification.Name(rawValue: Setting.showNSFW.rawValue), object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage.image(withColor: .clear, size: CGSize(width: 1, height: 1))
        navigationController?.navigationBar.setBackgroundImage(UIImage.image(withColor: UIColor.mainColor, size: CGSize(width: 1, height: 1)), for: UIBarMetrics.default)
        
        let searchBarButton = UIImage(named: "Search")!.navigationBarButton(action: { [unowned self] (sender) -> Void in
            self.toggleSearchBar()
            })
        navigationItem.setRightBarButtonItems([navigationItem.rightBarButtonItem!, searchBarButton], animated: false)
        
        categorySegmentedBarView.segmentedControl.setLocalizedTitles(["photo_grid_category_popular", "photo_grid_category_highest_rating", "photo_grid_category_upcoming", "photo_grid_category_favorite"])
        
        categorySegmentedBarView.searchBar.delegate = self
        
        layoutCollectionView()
        
        imageCollectionView.accessibilityLabel = "PhotoGridCollectionView"
        
        let cellIdentifier = "KGImageCell"
        imageDataSource = KGImageCollectionViewDataSource(cellIdentifier: cellIdentifier)
        imageCollectionView.dataSource = imageDataSource
        imageCollectionView!.register(KGImageCell.classForCoder(), forCellWithReuseIdentifier: cellIdentifier)
        
        refreshControl.backgroundColor = UIColor.mainColor
        refreshControl.tintColor = UIColor.white
        imageCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(PhotoGridViewController.reloadImages), for: UIControlEvents.valueChanged)
        
        updateImages()
        
        appLoader.isHidden = true
        logoImage.animate()
        splashView.animateNext { [unowned self] () -> () in
            if self.loading {
                self.appLoader.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.showImage.rawValue {
            navigationController!.navigationBar.topItem!.title = "text_back".localize();
            let detailViewController = segue.destination as! ImagePagerViewController
            detailViewController.images = imageDataSource.data
            detailViewController.currentIndex = sender as! Int
        }
    }
    
    // MARK: - Load Images methods
    
    func reloadImages() {
        imageDataSource.reset()
        currentPage = 1
        
        imageCollectionView.reloadData()
        
        guard currentCategory != .favorites else {
            loadFavorites()
            return
        }
        updateImages()
    }
    
    override func stopLoading() {
        super.stopLoading()
        refreshControl.endRefreshing()
    }
    
    func loadFavorites() {
        let cachedImages = ImageData.getAllImageDataFromCoreData()
        imageDataSource.insertData(cachedImages, inCollectionView: imageCollectionView)
    }
    
    func updateImages() {
        guard currentCategory != .favorites else { return }
        guard !loading else { return }
        
        startLoading()
        
        var request: URLRequestConvertible!
        if searching {
            request = API.Router.searchImages(["page": currentPage, "feature": currentCategory.rawValue, "term": searchTerm])
        } else {
            request = API.Router.getImages(["page": currentPage, "feature": currentCategory.rawValue])
        }
        
        RequestController.performJSONRequest(request: request) {
            [weak self] response in
            guard let strongSelf = self else { return }
            
            strongSelf.stopLoading()
            guard response.error == nil && response.responseData != nil else {
                // Request failed
                let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (alertAction) in
                    strongSelf.updateImages()
                })
                
                strongSelf.showAlertController(withTitle: "error_loading_images_title".localize(), andMessage: "error_loading_images_message".localize(), andActions: [okAction, tryAgainAction])
                
                return
            }
            
            // Request succeeded
            let showNSFW = Setting.showNSFW.isTrue()
            let resultImages = response.responseData!["photos"].arrayValue
            let newImages = strongSelf.parseImages(fromData: resultImages, showNSFW: showNSFW)
            strongSelf.imageDataSource.insertData(newImages, inCollectionView: strongSelf.imageCollectionView)
            strongSelf.currentPage += 1
        }
    }
    
    func parseImages(fromData data: [JSON], showNSFW: Bool) -> [ImageData] {
        guard currentCategory != .favorites else { return [] }
        return data.flatMap({ (jsonObject) -> ImageData? in
            if !showNSFW && jsonObject.dictionaryValue["nsfw"]!.boolValue == true {
                return nil
            }
            return ImageData(data: jsonObject.dictionaryValue)
        })
    }
    
    @IBAction func didSelectCategory(_ sender: AnyObject) {
        let segmentedControl = sender as! UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            currentCategory = .highestRating
        case 2:
            currentCategory = .upcoming
        case 3:
            currentCategory = .favorites
        default:
            currentCategory = .popular
        }
        
        reloadImages()
    }
    
}

extension PhotoGridViewController: UIScrollViewDelegate {
    
    // MARK: - Scroll View Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            updateImages()
        }
    }
    
}

extension PhotoGridViewController: UICollectionViewDelegate {
    
    // MARK: - Collection View Methods
    
    func layoutCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        var itemSize = UIScreen.main.bounds.width/CGFloat(cellsPerRow)
        itemSize -= (sectionInset*2.0)-(CGFloat(cellsPerRow-1)*cellSpacing)
        
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset)
        flowLayout.minimumInteritemSpacing = cellSpacing
        flowLayout.minimumLineSpacing = cellSpacing
        
        imageCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.showImage.rawValue, sender: (indexPath as NSIndexPath).item)
    }
    
}

extension PhotoGridViewController: UISearchBarDelegate {
    
    // MARK: - Search Bar Methods
    
    @IBAction func didTapDisableView(_ sender: AnyObject) {
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
        disableView.isHidden = true
        
        categorySegmentedBarView.closeSearchBar()
        categorySegmentedBarView.searchBar.resignFirstResponder()
        
        if searching {
            searching = false
            searchTerm = ""
            
            reloadImages()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        disableView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        disableView.isHidden = true
        
        searching = true
        searchTerm = searchBar.text!
        
        searchBar.resignFirstResponder()
        
        reloadImages()
    }
    
}

extension PhotoGridViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = imageCollectionView.indexPathForItem(at: location) else { return nil }
        guard let cell = imageCollectionView.cellForItem(at: indexPath) else { return nil }
        guard let detailViewController = storyboard?.viewController(withViewType: .imagePager) as? ImagePagerViewController else { return nil }
        
        // Add data to detail view
        detailViewController.images = imageDataSource.data
        detailViewController.currentIndex = indexPath.item
        currentIndex = indexPath.item
        
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 300)
        
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
