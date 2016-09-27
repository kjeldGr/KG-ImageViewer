//
//  LAAPI.swift
//  Scaffold Default
//
//  Created by Kjeld Groot on 11/08/15.
//  Copyright (c) 2015 Label A. All rights reserved.
//

import UIKit
import Alamofire

enum ImageSize: Int {
    case tiny = 1
    case small = 2
    case medium = 3
    case large = 4
    case xLarge = 5
}

struct API {
    
    enum Router: URLRequestConvertible {
        /// Returns a URL request or throws if an `Error` was encountered.
        ///
        /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
        ///
        /// - returns: A URL request.
        public func asURLRequest() throws -> URLRequest {
            return urlRequest
        }

        static let baseURLString = "https://api.500px.com/v1"
        static let consumerKey = "1cpVOiEnzp9QEYoIIlU0qgww77ayOHTVSLbasWSa"
        
        case getImages([String: Any])
        case searchImages([String: Any])
        case getImage(Int, [String: Any])
        
        var urlRequest: URLRequest {
            let (path, parameters, method): (String, [String: Any], Alamofire.HTTPMethod) = {
                switch self {
                case .getImages (let params):
                    var requestParams: [String: Any] = ["consumer_key": Router.consumerKey, "rpp": "50"]
                    requestParams.update(params)
                    return ("/photos", requestParams, .get)
                case .searchImages (let params):
                    var requestParams: [String: Any] = ["consumer_key": Router.consumerKey, "rpp": "50",  "include_store": "store_download"]
                    requestParams.update(params)
                    return ("/photos/search", requestParams, .get)
                case .getImage(let imageId, let params):
                    var requestParams: [String: Any] = ["consumer_key": Router.consumerKey]
                    requestParams.update(params)
                    return ("/photos/\(imageId)", requestParams, .get)
                }
                }()
            
            let URL = Foundation.URL(string: Router.baseURLString)
            var request = URLRequest(url: URL!.appendingPathComponent(path))
            request.httpMethod = method.rawValue
            
            let encoding: ParameterEncoding = method == .post ? Alamofire.JSONEncoding() : Alamofire.URLEncoding()
            
            var returnRequest: URLRequest?
            do {
               returnRequest = try encoding.encode(request, with: parameters)
            } catch {
                returnRequest = request
            }
            return returnRequest!
        }
    }
}
