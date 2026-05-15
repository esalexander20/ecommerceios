//
//  HTTPMethod.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

/// HTTP request methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    
    public var description: String {
        return rawValue
    }
}
