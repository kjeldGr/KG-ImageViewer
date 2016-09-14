//
//  ImageDataCoreData.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 12-09-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImageDataCoreData: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        added = NSDate()
    }
    
    func imageData() -> ImageData {
        return ImageData(coreDataModel: self)
    }

}
