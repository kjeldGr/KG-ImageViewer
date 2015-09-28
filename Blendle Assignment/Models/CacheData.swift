//
//  CacheData.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 27-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit

class CacheData: NSObject {
    static let sharedInstance = CacheData()
    let thumbnailCache = NSCache()
    let imageCache = NSCache()
    
}
