//
//  StringExtension.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import Foundation

extension String {
    
    func localize(fromTable table: String? = nil) -> String {
        return NSLocalizedString(self, tableName: table, comment: "")
    }
    
}
