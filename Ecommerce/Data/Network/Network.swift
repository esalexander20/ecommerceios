//
//  Network.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

/// Network layer exports - Import this file to access all networking components
///
/// Contains:
/// - APIClient: Main networking client with Combine support
/// - APIClientProtocol: Protocol for API client (mocking, DI)
/// - APIError: Custom error type for API errors
/// - APIEndpoint: Protocol for defining API endpoints
/// - HTTPMethod: HTTP request methods
/// - RequestInterceptor: Protocol for request interception
/// - DefaultRequestInterceptor, LoggingInterceptor: Interceptor implementations
/// - MockAPIClient: Mock client for testing
///
/// Endpoints:
/// - AuthEndpoint: Authentication endpoints
/// - ProductEndpoint: Product and category endpoints
/// - CartEndpoint: Shopping cart endpoints
/// - OrderEndpoint: Order and payment endpoints
/// - UserEndpoint: User profile endpoints

public enum Network {
    // Namespace for documentation
}
