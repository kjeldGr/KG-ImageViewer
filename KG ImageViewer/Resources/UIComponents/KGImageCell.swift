//
//  KGImageCell.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit

class KGImageCell: UICollectionViewCell {
    var imageURL: String! {
        didSet {
            loadImage(url: imageURL)
        }
    }
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        accessibilityLabel = "ImageCell"
        
        backgroundColor = UIColor.white
        
        addSubview(imageView)
        imageView.frame = bounds
    }
    
    func loadImage(url: String) {
        if let image = CacheData.sharedInstance.thumbnailCache.object(forKey: imageURL as AnyObject) as? UIImage {
            imageView.image = image
            return
        }
        let urlRequest = try! URLRequest(url: url, method: .get)
        RequestController.performImageRequest(request: urlRequest, completion: {
            [weak self] response in
            guard let strongSelf = self else { return }
            guard let image = response.responseData else { return }
            
            CacheData.sharedInstance.thumbnailCache.setObject(image, forKey: url as AnyObject)
            strongSelf.imageView.image = image
        })
    }
}
