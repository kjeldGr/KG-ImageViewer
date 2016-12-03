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
        
        backgroundImageView.image = UIImage.image(withColor: UIColor.white, size: CGSize(width: 1, height: 1)).applyBlurWithRadius(5, tintColor: UIColor.mainColor.withAlphaComponent(0.5), saturationDeltaFactor: 1.8)
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
        RequestController.performJSONRequest(request: API.Router.getImage(imageData.id, ["image_size": ImageSize.xLarge.rawValue])) {
            [weak self] response in
            guard let strongSelf = self else { return }
            guard response.error == nil && response.responseData != nil else {
                strongSelf.stopLoading()
                let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (action) -> Void in
                    strongSelf.getDetailedImageData()
                })
                
                strongSelf.showAlertController(withTitle: "error_loading_image_title".localize(), andMessage: "error_loading_images_message".localize(), andActions: [okAction, tryAgainAction])
                return
            }
            strongSelf.loadImage(forData: response.responseData!["photo"].dictionaryValue)
        }
    }
    
    func loadImage(forData data: [String: JSON]) {
        let url = data["image_url"]!.stringValue
        let urlRequest = try! URLRequest(url: url, method: .get)
        RequestController.performImageRequest(request: urlRequest) {
            [weak self] response in
            
            guard let strongSelf = self else { return }
            strongSelf.stopLoading()
            
            let image = response.responseData
            guard response.error == nil && image != nil else {
                let okAction = UIAlertAction(title: "error_button_ok".localize(), style: .default, handler: nil)
                let tryAgainAction = UIAlertAction(title: "error_button_try_again".localize(), style: .default, handler: { (action) -> Void in
                    strongSelf.loadImage(forData: data)
                })
                
                strongSelf.showAlertController(withTitle: "error_loading_image_title".localize(), andMessage: "error_loading_images_message".localize(), andActions: [okAction, tryAgainAction])
                return
            }
            
            strongSelf.setImage(image!)
            let saveImage = Setting.saveHighRes.isTrue()
            if saveImage {
                CacheData.sharedInstance.imageCache.setObject(image!, forKey: strongSelf.imageData.id as AnyObject)
            }
        }
    }
    
    func setImage(_ image: UIImage) {
        detailImage = image
        imageView.image = image
        backgroundImageView.image = image.applyBlurWithRadius(5, tintColor: UIColor.mainColor.withAlphaComponent(0.5), saturationDeltaFactor: 1.8)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

}
