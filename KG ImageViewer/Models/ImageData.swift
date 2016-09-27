//
//  ImageData.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ImageData: NSObject {
    var id: Int!
    var url: String!
    var name: String!
    var nsfw: Bool!
    
    init(data: [String: JSON]) {
        super.init()
        id = data["id"]?.intValue
        name = data["name"]?.stringValue
        url = data["image_url"]?.stringValue
        nsfw = data["nsfw"]?.boolValue
    }
    
    init(coreDataModel: ImageDataCoreData) {
        super.init()
        id = coreDataModel.id?.intValue
        name = coreDataModel.name!
        url = coreDataModel.url!
        nsfw = false
    }
    
    func valuesForCoreDataObject() -> [String: AnyObject] {
        return ["id": NSNumber(value: id as Int), "name": name as AnyObject, "url": url as AnyObject]
    }
    
    func isFavorite() -> Bool {
        return CoreDataManager.getManagedObject(withId: NSNumber(value: id as Int), entityName: "ImageDataCoreData") != nil
    }
    
    class func getAllImageDataFromCoreData() -> [ImageData] {
        let imageDataObjects: [ImageDataCoreData] = CoreDataManager.getManagedObjects(withEntityName: ImageDataCoreData.className)
        // Sort the images on date added
        return imageDataObjects.sorted(by: { (first, second) -> Bool in
            return first.added > second.added
        }).map({ (object) -> ImageData in
            object.imageData()
        })
    }
    
}
