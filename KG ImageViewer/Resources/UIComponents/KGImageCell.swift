//
//  KGImageCell.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Alamofire

class KGImageCell: UICollectionViewCell {
    var request: Alamofire.Request?
    let imageView = UIImageView()
    
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
        
        backgroundColor = UIColor.whiteColor()
        
        addSubview(imageView)
        imageView.frame = bounds
    }
}
