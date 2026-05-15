//
//  APIEndpoint.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import UIKit

/// Protocol for API endpoints
public protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: Any]? { get }
    var bodyParameters: [String: Any]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

public extension APIEndpoint {
    var baseURL: URL {
        // Default base URL - should be configured via AppConfig
        return URL(string: "https://api.ecommerceapp.com/v1")!
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        return nil
    }
    
    var bodyParameters: [String: Any]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var timeoutInterval: TimeInterval {
        return 30.0
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    /// Constructs the full URL for the endpoint
    var url: URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        return components.url!
    }
    
    /// Creates a URLRequest for this endpoint
    func makeRequest(accessToken: String? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy
        
        // Add default headers
        var allHeaders: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-App-Version": AppInfo.version,
            "X-Platform": "iOS",
            "X-Device-ID": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]
        
        // Merge endpoint headers
        if let headers = headers {
            allHeaders.merge(headers) { (current, new) in new }
        }
        
        // Add authorization token if available
        if let accessToken = accessToken {
            allHeaders["Authorization"] = "Bearer " + accessToken
        }
        
        request.allHTTPHeaderFields = allHeaders
        
        // Add body if present
        if let body = body {
            request.httpBody = body
        } else if let bodyParameters = bodyParameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        }
        
        return request
    }
}

// MARK: - App Info

public enum AppInfo {
    public static var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public static var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    public static var versionWithBuild: String {
        return "\(version) (\(build))"
    }
}
