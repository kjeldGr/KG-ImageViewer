//
//  Extensions.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 14-12-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

func DLog(_ items: Any..., function: String = #function, separator: String = " ") {
    // Before you can use this please make sure you added the "-DDEBUG" flag to: Swift Compiler - Custom Flags->Other
    var output = "\(function): "
    for item in items {
        output += "\(separator)\(item)"
    }
    #if DEBUG
        print(output)
    #endif
}
