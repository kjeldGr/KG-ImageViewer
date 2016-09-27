//
//  CoreDataManager.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 13-09-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    class func managedContextFromDelegate() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    class func getManagedObjects<T>(withEntityName entityName: String) -> [T] where T: NSManagedObject {
        let managedContext = managedContextFromDelegate()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let managedObjects = results.flatMap({ (result) -> T? in
                guard let managedObject = result as? T else { return nil }
                return managedObject
            })
            return managedObjects
        } catch let error as NSError {
            error.DLog("Error: \(error)\nWhile fetchin core data objects")
            return [T]()
        }
    }
    
    class func getManagedObject<T>(withId id: NSNumber, entityName: String) -> T? where T: NSManagedObject {
        let returnObject: T? = CoreDataManager.getManagedObjects(withEntityName: entityName).filter({ (managedObject) -> Bool in
            return (managedObject as NSManagedObject).value(forKey: "id") as! NSNumber == id
        }).first
        return returnObject
    }
    
    @discardableResult class func saveManagedObject<T>(withEntityName entityName: String, values: [String: AnyObject], save: Bool = true, shouldBeUnique unique: Bool = true) -> T? where T: NSManagedObject {
        guard let objectId = values["id"] as? NSNumber else { return nil }
        
        let managedContext = managedContextFromDelegate()
        
        var managedObject: T? = getManagedObject(withId: objectId, entityName: entityName)
        if save && (managedObject == nil && unique) {
            // When the object should be unique, only save when a managedObject with the specific id doesn't exist yet
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
            
            managedObject = T(entity: entity, insertInto: managedContext)
            for (key, value) in values {
                (managedObject as! NSManagedObject).setValue(value, forKey: key)
            }
        } else if managedObject != nil {
            // Delete if save is false
            deleteManagedObject(managedObject!)
            managedObject = nil
        }
        
        do {
            try managedContextFromDelegate().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return managedObject
    }
    
    class func deleteManagedObject<T>(_ object: T) where T: NSManagedObject {
        let managedContext = managedContextFromDelegate()
        managedContext.delete(object)
    }
    
}
