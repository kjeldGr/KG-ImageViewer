//
//  RequestController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 24-11-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum LoadingError: Error {
    case imageParseFailed
}

protocol DataRequestResponse {
    associatedtype dataType
    var responseData: dataType? { get }
    var error: Error? { get }
}

struct RequestResponse<T>: DataRequestResponse {
    typealias dataType = T
    let responseData: T?
    let error: Error?
    
    init(_ responseData: T?, error: Error?) {
        self.error = error
        self.responseData = responseData
    }
}

class RequestController {
    
    class func performJSONRequest(request: URLRequestConvertible, completion: @escaping ((RequestResponse<JSON>) -> Void)) {
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                let requestResponse: RequestResponse<JSON> = requestResponseFromResult(response.result)
                completion(requestResponse)
        }
    }
    
    class func performImageRequest(request: URLRequestConvertible, completion: @escaping ((RequestResponse<UIImage>) -> Void)) {
        Alamofire.request(request)
            .validate(contentType: ["image/*"])
            .responseData { response -> Void in
                let requestResponse: RequestResponse<UIImage> = requestResponseFromResult(response.result)
                completion(requestResponse)
        }
    }
    
    class func requestResponseFromResult<T, D>(_ result: Alamofire.Result<D>) -> RequestResponse<T> {
        var responseData: T? = nil
        var responseError: Error? = nil
        switch result {
        case .success(let data):
            if T.self == JSON.self {
                responseData = JSON(data) as? T
            } else if T.self == UIImage.self {
                if let image = UIImage(data: data as! Data, scale: UIScreen.main.scale) {
                    responseData = image as? T
                } else {
                    responseError = LoadingError.imageParseFailed
                }
            }
        case .failure(let error):
            responseError = error
        }
        return RequestResponse(responseData, error: responseError)
    }
    
}
