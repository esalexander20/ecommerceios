//
//  APIClient.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import Combine

/// Protocol for API client to enable mocking and dependency injection
public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<T, APIError>
    func requestData(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<Data, APIError>
    func requestVoid(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<Void, APIError>
    func downloadFile(from url: URL) -> AnyPublisher<Data, APIError>
}

/// Main API client implementation using URLSession and Combine
public final class APIClient: APIClientProtocol {
    
    public static let shared = APIClient()
    
    private let session: URLSessionProtocol
    private let baseURL: URL
    private let interceptor: RequestInterceptor?
    
    public var onRequest: ((URLRequest) -> Void)?
    public var onResponse: ((HTTPURLResponse?, Any?) -> Void)?
    public var onError: ((APIError) -> Void)?
    
    public init(
        session: URLSessionProtocol = URLSession.shared,
        baseURL: URL? = nil,
        interceptor: RequestInterceptor? = nil
    ) {
        self.session = session
        self.baseURL = baseURL ?? URL(string: "https://api.ecommerceapp.com/v1")!
        self.interceptor = interceptor
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint, accessToken: String? = nil) -> AnyPublisher<T, APIError> {
        do {
            var request = try endpoint.makeRequest(accessToken: accessToken)
            
            if self.baseURL != endpoint.baseURL {
                let components = URLComponents(url: self.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
                request.url = components.url
            }
            
            if let interceptor = interceptor {
                request = try interceptor.intercept(request)
            }
            
            onRequest?(request)
            
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response -> Data in
                    self?.logResponse(response, data: data)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    if data.isEmpty { throw APIError.invalidResponse }
                    return data
                }
                .tryMap { data -> T in
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        self.onResponse?(nil, decoded)
                        return decoded
                    } catch let decodingError {
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                            let apiError = APIError.from(
                                statusCode: errorResponse.status ?? 500,
                                message: errorResponse.message,
                                errors: errorResponse.errors
                            )
                            self.onError?(apiError)
                            throw apiError
                        }
                        throw APIError.decodingError(decodingError)
                    }
                }
                .mapError { error in
                    let apiError = self.handleError(error)
                    self.onError?(apiError)
                    return apiError
                }
                .eraseToAnyPublisher()
            
        } catch let error {
            let apiError = handleError(error)
            onError?(apiError)
            return Fail(error: apiError).eraseToAnyPublisher()
        }
    }
    
    public func requestData(_ endpoint: APIEndpoint, accessToken: String? = nil) -> AnyPublisher<Data, APIError> {
        do {
            var request = try endpoint.makeRequest(accessToken: accessToken)
            if self.baseURL != endpoint.baseURL {
                let components = URLComponents(url: self.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
                request.url = components.url
            }
            if let interceptor = interceptor {
                request = try interceptor.intercept(request)
            }
            onRequest?(request)
            
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response -> Data in
                    self?.logResponse(response, data: data)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    if data.isEmpty { throw APIError.invalidResponse }
                    return data
                }
                .mapError { error in
                    let apiError = self.handleError(error)
                    self.onError?(apiError)
                    return apiError
                }
                .eraseToAnyPublisher()
            
        } catch let error {
            let apiError = handleError(error)
            onError?(apiError)
            return Fail(error: apiError).eraseToAnyPublisher()
        }
    }
    
    public func requestVoid(_ endpoint: APIEndpoint, accessToken: String? = nil) -> AnyPublisher<Void, APIError> {
        requestData(endpoint, accessToken: accessToken)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    public func downloadFile(from url: URL) -> AnyPublisher<Data, APIError> {
        session.dataTaskPublisher(for: URLRequest(url: url))
            .tryMap { [weak self] data, response -> Data in
                self?.logResponse(response, data: data)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.from(statusCode: httpResponse.statusCode)
                }
                if data.isEmpty { throw APIError.invalidResponse }
                return data
            }
            .mapError { error in
                let apiError = self.handleError(error)
                self.onError?(apiError)
                return apiError
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private func handleError(_ error: Error) -> APIError {
        if let apiError = error as? APIError { return apiError }
        if let urlError = error as? URLError { return APIError.from(urlError: urlError) }
        if let decodingError = error as? DecodingError { return .decodingError(decodingError) }
        return .unknown(error)
    }
    
    private func logResponse(_ response: URLResponse?, data: Data) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        onResponse?(httpResponse, nil)
        #if DEBUG
        print("Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")")
        if let dataString = String(data: data, encoding: .utf8), data.count < 1000 {
            print("Response Data: \(dataString)")
        }
        #endif
    }
}

// MARK: - URLSession Protocol

public protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: URLSessionProtocol {
    public func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        self.dataTaskPublisher(for: request)
    }
}

// MARK: - Request Interceptor

public protocol RequestInterceptor {
    func intercept(_ request: URLRequest) throws -> URLRequest
}

public struct DefaultRequestInterceptor: RequestInterceptor {
    public func intercept(_ request: URLRequest) throws -> URLRequest {
        var modified = request
        var headers = modified.allHTTPHeaderFields ?? [:]
        headers["X-Request-ID"] = UUID().uuidString
        headers["X-Timestamp"] = String(Int(Date().timeIntervalSince1970 * 1000))
        modified.allHTTPHeaderFields = headers
        return modified
    }
}

public struct LoggingInterceptor: RequestInterceptor {
    public init() {}
    public func intercept(_ request: URLRequest) throws -> URLRequest {
        #if DEBUG
        print("Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields { print("Headers: \(headers)") }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        #endif
        return request
    }
}

// MARK: - Mock

public final class MockAPIClient: APIClientProtocol {
    public var requestHandler: ((APIEndpoint, String?) -> AnyPublisher<(Data, HTTPURLResponse), APIError>)?
    public var dataHandler: ((APIEndpoint, String?) -> AnyPublisher<Data, APIError>)?
    public var voidHandler: ((APIEndpoint, String?) -> AnyPublisher<Void, APIError>)?
    public var downloadHandler: ((URL) -> AnyPublisher<Data, APIError>)?
    private let error: APIError?
    
    public init(error: APIError? = nil) { self.error = error }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<T, APIError> {
        if let error = error { return Fail(error: error).eraseToAnyPublisher() }
        if let handler = requestHandler {
            return handler(endpoint, accessToken)
                .map { $0.0 }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { $0 as? APIError ?? .decodingError($0) }
                .eraseToAnyPublisher()
        }
        return Fail(error: .invalidResponse).eraseToAnyPublisher()
    }
    
    public func requestData(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<Data, APIError> {
        if let error = error { return Fail(error: error).eraseToAnyPublisher() }
        if let handler = dataHandler { return handler(endpoint, accessToken) }
        return Fail(error: .invalidResponse).eraseToAnyPublisher()
    }
    
    public func requestVoid(_ endpoint: APIEndpoint, accessToken: String?) -> AnyPublisher<Void, APIError> {
        if let error = error { return Fail(error: error).eraseToAnyPublisher() }
        if let handler = voidHandler { return handler(endpoint, accessToken) }
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
    
    public func downloadFile(from url: URL) -> AnyPublisher<Data, APIError> {
        if let error = error { return Fail(error: error).eraseToAnyPublisher() }
        if let handler = downloadHandler { return handler(url) }
        return Fail(error: .invalidResponse).eraseToAnyPublisher()
    }
}
