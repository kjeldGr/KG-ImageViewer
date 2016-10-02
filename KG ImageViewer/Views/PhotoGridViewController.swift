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
    case Upcoming = "upcoming"
    case Favorites = "favorites"
}

class PhotoGridViewController: KGViewController, MenuViewController {
    
    @IBOutlet weak var splashView: SpringView!
    @IBOutlet weak var logoImage: SpringImageView!
    @IBOutlet weak var categorySegmentedBarView: SegmentedBarView!
    @IBOutlet weak var disableView: UIView!
    
    fileprivate var currentCategory: Category = .Popular
    fileprivate var currentPage = 1
    fileprivate var searching = false
    fileprivate var searchTerm: String!
    fileprivate var images = [ImageData]()
    fileprivate var currentIndex = 0
    
    // Collection View properties
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let imageCellIdentifier = "KGImageCell"
    let sectionInset: CGFloat = 5
    let cellSpacing: CGFloat = 2
    let cellsPerRow = 4
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        title = "view_photo_grid_title".localize()
        
        super.viewDidLoad()
        
        // Check for 3D touch
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        imageCollectionView.accessibilityLabel = "PhotoGridCollectionView"
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoGridViewController.reloadImages), name: NSNotification.Name(rawValue: Setting.ShowNSFW.rawValue), object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage.image(withColor: .clear, size: CGSize(width: 1, height: 1))
        navigationController?.navigationBar.setBackgroundImage(UIImage.image(withColor: Helper.mainColor, size: CGSize(width: 1, height: 1)), for: UIBarMetrics.default)
        
        let searchBarButton = UIImage(named: "Search")!.navigationBarButton(action: { [unowned self] (sender) -> Void in
            self.toggleSearchBar()
            })
        navigationItem.setRightBarButtonItems([navigationItem.rightBarButtonItem!, searchBarButton], animated: false)
        
        categorySegmentedBarView.segmentedControl.setLocalizedTitles(["photo_grid_category_popular", "photo_grid_category_highest_rating", "photo_grid_category_upcoming", "photo_grid_category_favorite"])
        
        categorySegmentedBarView.searchBar.delegate = self
        
        layoutCollectionView()
        
        imageCollectionView!.register(KGImageCell.classForCoder(), forCellWithReuseIdentifier: imageCellIdentifier)
        
        refreshControl.backgroundColor = Helper.mainColor
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
            detailViewController.images = images
            detailViewController.currentIndex = sender as! Int
        }
    }
    
    // MARK: - Load Images methods
    
    func reloadImages() {
        images.removeAll()
        currentPage = 1
        
        imageCollectionView.reloadData()
        
        guard currentCategory != .Favorites else {
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
        images = ImageData.getAllImageDataFromCoreData()
        imageCollectionView.reloadData()
    }
    
    func updateImages() {
        guard currentCategory != .Favorites else { return }
        guard !loading else { return }
        
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
                case .success(let data):
                    let resultData = JSON(data)
                    DispatchQueue.global(qos: .default).async {
                        let lastItem = strongSelf.images.count
                        
                        let showNSFW = Setting.ShowNSFW.isTrue()
                        let resultImages = resultData["photos"].arrayValue
                        strongSelf.addImages(resultImages, showNSFW: showNSFW)
                        
                        let indexPaths = (lastItem..<strongSelf.images.count).map { IndexPath(item: $0, section: 0) }
                        DispatchQueue.main.async {
                            strongSelf.insertImagesInCollectionView(forIndexPaths: indexPaths)
                        }
                    }
                case .failure(_):
                    let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (alertAction) in
                        strongSelf.updateImages()
                    })
                    
                    let alertController = strongSelf.alertController(withTitle: "error_loading_images_title".localize(), andMessage: "error_loading_images_message".localize(), andStyle: .alert, andActions: [okAction, tryAgainAction])
                    strongSelf.present(alertController, animated: true, completion: nil)
                    
                    strongSelf.stopLoading()
                }
        }
    }
    
    func addImages(_ resultImages: [JSON], showNSFW: Bool) {
        guard currentCategory != .Favorites else { return }
        images += resultImages.flatMap {
            if !showNSFW && $0.dictionaryValue["nsfw"]!.boolValue == true {
                return nil
            }
            return ImageData(data: $0.dictionaryValue)
        }
    }
    
    func insertImagesInCollectionView(forIndexPaths indexPaths: [IndexPath]) {
        guard currentCategory != .Favorites else { return }
        
        if images.count < indexPaths.count {
            return
        }
        imageCollectionView!.insertItems(at: indexPaths)
        currentPage += 1
        stopLoading()
    }
    
    @IBAction func didSelectCategory(_ sender: AnyObject) {
        let segmentedControl = sender as! UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            currentCategory = .HighestRating
        case 2:
            currentCategory = .Upcoming
        case 3:
            currentCategory = .Favorites
        default:
            currentCategory = .Popular
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

extension PhotoGridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func layoutCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        
        var itemSize = UIScreen.main.bounds.width/CGFloat(cellsPerRow)
        itemSize -= (sectionInset*2.0)-(CGFloat(cellsPerRow-1)*cellSpacing)
        
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        
        imageCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as! KGImageCell
        
        let imageURL = images[(indexPath as NSIndexPath).item].url
        cell.request?.cancel()
        
        if let image = CacheData.sharedInstance.thumbnailCache.object(forKey: imageURL as AnyObject) as? UIImage {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            cell.request = Alamofire.request(imageURL!, method: .get)
                .validate(contentType: ["image/*"])
                .responseData { response -> Void in
                    switch response.result {
                    case .success(let data):
                        let image = UIImage(data: data, scale: UIScreen.main.scale)
                        CacheData.sharedInstance.thumbnailCache.setObject(image!, forKey: response.request!.url!.absoluteString as AnyObject)
                        cell.imageView.image = image
                    case .failure(_):
                        break
                    }
            }
        }
        
        return cell
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
        detailViewController.images = images
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
