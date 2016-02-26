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
            .responseJSON(completionHandler: { [unowned self] (request, response, result) -> Void in
                switch result {
                case .Success(let data):
                    let imageDetailData = JSON(data).dictionaryValue
                    self.loadImageForData(imageDetailData["photo"]!.dictionaryValue)
                case Result.Failure(_, _):
                    self.stopLoading()
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default, handler: { [unowned self] (action) -> Void in
                        self.getDetailedImageData()
                    })
                    
                    let alertController = self.alertControllerWithTitle(NSLocalizedString("error_loading_image_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
    }
    
    func loadImageForData(data: [String: JSON]) {
        Alamofire.request(Alamofire.Method.GET, data["image_url"]!.stringValue)
            .validate(contentType: ["image/*"])
            .responseData({ [unowned self] (request, response, result) -> Void in
                switch result {
                case .Success(let data):
                    let image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
                    self.setImage(image!)
                    let saveImage = NSUserDefaults.standardUserDefaults().boolForKey(Setting.SaveHighRes.rawValue)
                    if saveImage {
                        CacheData.sharedInstance.imageCache.setObject(image!, forKey: self.imageData.id)
                    }
                    self.stopLoading()
                case .Failure(_, _):
                    let okAction = UIAlertAction(title: NSLocalizedString("error_button_ok", comment: ""), style: .Default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: NSLocalizedString("error_button_try_again", comment: ""), style: .Default, handler: { [unowned self] (action) -> Void in
                        self.loadImageForData(data)
                    })
                    
                    let alertController = self.alertControllerWithTitle(NSLocalizedString("error_loading_image_title", comment: ""), andMessage: NSLocalizedString("error_loading_images_message", comment: ""), andStyle: .Alert, andActions: [okAction, tryAgainAction])
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.stopLoading()
                }
            })
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
