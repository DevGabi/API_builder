//
//  RequestBuilder.swift
//  CommonAPI
//
//  Created by DevGabi on 2020/08/10.
//  Copyright © 2020 devgabi. All rights reserved.
//

import Foundation
import Alamofire

class RequestBuilder: RequestBuilderType {
    var httpMethod: HTTPMethod = .get
    var headerField: HTTPHeaders = .default
    var responseData: ResponseDataType = .data
    var urlComponents = URLComponents()
    func httpMethod(method: HTTPMethod) -> RequestBuilderType {
        httpMethod = method
        return self
    }
    func setHeaderField(field: HTTPHeaders) -> RequestBuilderType {
        headerField = field
        return self
    }
    @discardableResult
    func setScheme(scheme: SchemeType) -> RequestBuilderType {
        urlComponents.scheme = scheme.string()
        return self
    }
    @discardableResult
    func setDomain(domain: String) -> RequestBuilderType {
        urlComponents.host = domain
        return self
    }
    @discardableResult
    func setPath(path: String) -> RequestBuilderType {
        urlComponents.path = path
        return self
    }
    @discardableResult
    func setQuary(query: [String : String]) -> RequestBuilderType {
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value)}
        return self
    }
    
    func build(_ responseType: ResponseDataType = .data) -> URLComponents {
        print(urlComponents.url?.absoluteString ?? "")
        responseData = responseType
        return urlComponents
    }
}
