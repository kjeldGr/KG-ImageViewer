//
//  CacheData.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 27-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Foundation

class CacheData: NSObject {
    static let sharedInstance = CacheData()
    let thumbnailCache = NSCache<AnyObject, AnyObject>()
    let imageCache = NSCache<AnyObject, AnyObject>()
    
}
