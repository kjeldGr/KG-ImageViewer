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
        
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0/UIScreen.main.scale)
        navigationController?.navigationBar.layer.shadowRadius = 0
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.25
        
        backgroundImageView.image = UIImage.image(withColor: UIColor.white, size: CGSize(width: 1, height: 1)).applyBlurWithRadius(5, tintColor: Helper.mainColor.withAlphaComponent(0.5), saturationDeltaFactor: 1.8)
        backgroundImageView.frame = view.bounds
        imageView.frame = view.bounds
        
        if let image = CacheData.sharedInstance.imageCache.object(forKey: imageData.id as AnyObject) as? UIImage {
            setImage(image)
        } else {
            getDetailedImageData()
        }
    }
    
    func getDetailedImageData() {
        startLoading()
        Alamofire.request(API.Router.getImage(imageData.id, ["image_size": ImageSize.xLarge.rawValue])).validate()
            .responseJSON(completionHandler: { [weak self] result -> Void in
                guard let strongSelf = self else { return }
                switch result.result {
                case .success(let data):
                    let imageDetailData = JSON(data).dictionaryValue
                    strongSelf.loadImage(forData: imageDetailData["photo"]!.dictionaryValue)
                case Result.failure(_):
                    strongSelf.stopLoading()
                    let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (action) -> Void in
                        strongSelf.getDetailedImageData()
                    })
                    
                    let alertController = strongSelf.alertController(withTitle: "error_loading_image_title".localize(), andMessage: "error_loading_images_message".localize(), andStyle: .alert, andActions: [okAction, tryAgainAction])
                    strongSelf.present(alertController, animated: true, completion: nil)
                }
            })
    }
    
    func loadImage(forData data: [String: JSON]) {
        Alamofire.request(data["image_url"]!.stringValue, method: .get)
            .validate(contentType: ["image/*"])
            .responseData { [weak self] response -> Void in
                guard let strongSelf = self else { return }
                switch response.result {
                case .success(let data):
                    let image = UIImage(data: data, scale: UIScreen.main.scale)
                    strongSelf.setImage(image!)
                    let saveImage = Setting.SaveHighRes.isTrue()
                    if saveImage {
                        CacheData.sharedInstance.imageCache.setObject(image!, forKey: strongSelf.imageData.id as AnyObject)
                    }
                    strongSelf.stopLoading()
                case .failure(_):
                    let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                    let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (action) -> Void in
                        strongSelf.loadImage(forData: data)
                    })
                    
                    let alertController = strongSelf.alertController(withTitle: "error_loading_image_title".localize(), andMessage: "error_loading_images_message".localize(), andStyle: .alert, andActions: [okAction, tryAgainAction])
                    strongSelf.present(alertController, animated: true, completion: nil)
                    strongSelf.stopLoading()
                }
            }
    }
    
    func setImage(_ image: UIImage) {
        detailImage = image
        imageView.image = image
        backgroundImageView.image = image.applyBlurWithRadius(5, tintColor: Helper.mainColor.withAlphaComponent(0.5), saturationDeltaFactor: 1.8)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

}
