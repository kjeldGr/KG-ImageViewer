//
//  LAAPI.swift
//  Scaffold Default
//
//  Created by Kjeld Groot on 11/08/15.
//  Copyright (c) 2015 Label A. All rights reserved.
//

import UIKit
import Alamofire

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

enum ImageSize: Int {
    case Tiny = 1
    case Small = 2
    case Medium = 3
    case Large = 4
    case XLarge = 5
}

struct API {
    
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.500px.com/v1"
        static let consumerKey = "1cpVOiEnzp9QEYoIIlU0qgww77ayOHTVSLbasWSa"
        
        case getImages([String: AnyObject])
        case getImage(Int, [String: AnyObject])
        
        var URLRequest: NSMutableURLRequest {
            let (path, parameters, method): (String, [String: AnyObject], Alamofire.Method) = {
                switch self {
                case .getImages (let params):
                    var requestParams: [String: AnyObject] = ["consumer_key": Router.consumerKey, "rpp": "50",  "include_store": "store_download"]
                    requestParams.update(params)
                    return ("/photos", requestParams, Alamofire.Method.GET)
                case .getImage(let imageId, let params):
                    var requestParams: [String: AnyObject] = ["consumer_key": Router.consumerKey]
                    requestParams.update(params)
                    return ("/photos/\(imageId)", requestParams, Alamofire.Method.GET)
                }
                }()
            
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            URLRequest.HTTPMethod = method.rawValue
            
            let encoding = method == Alamofire.Method.POST ? Alamofire.ParameterEncoding.JSON : Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}