//
//  DictionaryExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

extension Dictionary {
    
    mutating func update(_ other: Dictionary) {
        for (key, value) in other {
            updateValue(value, forKey: key)
        }
    }
    
}
