//
//  ImageDataCoreData+CoreDataProperties.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 13-09-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ImageDataCoreData {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var url: String?
    @NSManaged var added: NSDate?

}
