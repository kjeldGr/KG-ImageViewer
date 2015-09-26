//
//  ImageData.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import SwiftyJSON

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
}
