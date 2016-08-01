//
//  ImageDetailViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImageDetailViewController: KGViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var detailImage: UIImage!
    var imageData: ImageData!
    
    override func viewDidLoad() {
        title = imageData.name
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, 1.0/UIScreen.mainScreen().scale)
        navigationController?.navigationBar.layer.shadowRadius = 0
        navigationController?.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.25
        
        backgroundImageView.image = UIImage.imageWithColor(UIColor.whiteColor(), size: CGSizeMake(1, 1)).applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8)
        backgroundImageView.frame = view.bounds
        imageView.frame = view.bounds
        
        if let image = CacheData.sharedInstance.imageCache.objectForKey(imageData.id) as? UIImage {
            setImage(image)
        } else {
            getDetailedImageData()
        }
    }
    
    func getDetailedImageData() {
        startLoading()
        Alamofire.request(API.Router.getImage(imageData.id, ["image_size": ImageSize.XLarge.rawValue])).validate()
            .responseJSON(completionHandler: { [weak self] result -> Void in
                guard let strongSelf = self else { return }
                switch result.result {
                case .Success(let data):
                    let imageDetailData = JSON(data).dictionaryValue
                    strongSelf.loadImageForData(imageDetailData["photo"]!.dictionaryValue)
                case Result.Failure(_):
                    strongSelf.stopLoading()
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default, handler: { (action) -> Void in
                        strongSelf.getDetailedImageData()
                    })
                    
                    let alertController = strongSelf.alertControllerWithTitle(NSLocalizedString("error_loading_image_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    strongSelf.presentViewController(alertController, animated: true, completion: nil)
                }
            })
    }
    
    func loadImageForData(data: [String: JSON]) {
        Alamofire.request(Alamofire.Method.GET, data["image_url"]!.stringValue)
            .validate(contentType: ["image/*"])
            .responseData { [weak self] response -> Void in
                guard let strongSelf = self else { return }
                switch response.result {
                case .Success(let data):
                    let image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
                    strongSelf.setImage(image!)
                    let saveImage = NSUserDefaults.standardUserDefaults().boolForKey(Setting.SaveHighRes.rawValue)
                    if saveImage {
                        CacheData.sharedInstance.imageCache.setObject(image!, forKey: strongSelf.imageData.id)
                    }
                    strongSelf.stopLoading()
                case .Failure(_):
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default, handler: { (action) -> Void in
                        strongSelf.loadImageForData(data)
                    })
                    
                    let alertController = strongSelf.alertControllerWithTitle(NSLocalizedString("error_loading_image_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    strongSelf.presentViewController(alertController, animated: true, completion: nil)
                    strongSelf.stopLoading()
                }
            }
    }
    
    func setImage(image: UIImage) {
        detailImage = image
        imageView.image = image
        backgroundImageView.image = image.applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

}
