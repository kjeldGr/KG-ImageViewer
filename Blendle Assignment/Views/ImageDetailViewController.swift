//
//  ImageDetailViewController.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImageDetailViewController: BlendleViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var imageData: ImageData!
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        title = imageData.name
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, 1.0/UIScreen.mainScreen().scale)
        navigationController?.navigationBar.layer.shadowRadius = 0
        navigationController?.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.25
        
        self.backgroundImageView.image = UIColor.whiteColor().imageWithSize(CGSizeMake(1, 1)).applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8)
        self.backgroundImageView.frame = self.view.bounds
        self.imageView.frame = self.view.bounds
        
        getDetailedImageData()
    }
    
    func getDetailedImageData() {
        startLoading()
        Alamofire.request(API.Router.getImage(imageData.id, ["image_size": ImageSize.XLarge.rawValue])).validate()
            .responseJSON(completionHandler: { (request, response, result) -> Void in
                switch result {
                case .Success(let data):
                    let imageDetailData = JSON(data).dictionaryValue
                    self.loadImageForData(imageDetailData["photo"]!.dictionaryValue)
                case Result.Failure(_, let error):
                    print(error)
                    self.stopLoading()
                }
            })
    }
    
    func loadImageForData(data: [String: JSON]) {
        Alamofire.request(Alamofire.Method.GET, data["image_url"]!.stringValue)
            .validate(contentType: ["image/*"])
            .responseData({ (request, response, result) -> Void in
                switch result {
                case .Success(let data):
                    let image = UIImage(data: data, scale: UIScreen.mainScreen().scale)
                    self.imageView.image = image
//                    self.imageView.frame = self.view.bounds
                    self.backgroundImageView.image = image!.applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8)
//                    self.backgroundImageView.frame = self.view.bounds
                    self.stopLoading()
                case .Failure(let errorData, _):
                    print("error: ", errorData)
                    self.stopLoading()
                }
            })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

}
