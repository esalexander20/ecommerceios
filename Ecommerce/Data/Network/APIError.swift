//
//  APIError.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

/// Custom error type for API-related errors
public enum APIError: Error, LocalizedError, Equatable {
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.serverUnreachable, .serverUnreachable):
            return true
        case (.requestTimeout, .requestTimeout):
            return true
        case (.invalidURL, .invalidURL):
            return true
        case (.badRequest(let lhsMessage), .badRequest(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.unauthorized(let lhsMessage), .unauthorized(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.forbidden(let lhsMessage), .forbidden(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.notFound(let lhsMessage), .notFound(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.methodNotAllowed, .methodNotAllowed):
            return true
        case (.requestTimeoutError, .requestTimeoutError):
            return true
        case (.conflict(let lhsMessage), .conflict(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.unprocessableEntity(let lhsErrors), .unprocessableEntity(let rhsErrors)):
            return lhsErrors == rhsErrors
        case (.rateLimited(let lhsRetry), .rateLimited(let rhsRetry)):
            return lhsRetry == rhsRetry
        case (.internalServerError(let lhsMessage), .internalServerError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.badGateway, .badGateway):
            return true
        case (.serviceUnavailable, .serviceUnavailable):
            return true
        case (.gatewayTimeout, .gatewayTimeout):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return "\(lhsError)" == "\(rhsError)"
        case (.invalidResponse, .invalidResponse):
            return true
        case (.serverError(let lhsCode, let lhsMessage), .serverError(let rhsCode, let rhsMessage)):
            return lhsCode == rhsCode && lhsMessage == rhsMessage
        case (.encodingError(let lhsError), .encodingError(let rhsError)):
            return "\(lhsError)" == "\(rhsError)"
        case (.missingParameters(let lhsParams), .missingParameters(let rhsParams)):
            return lhsParams == rhsParams
        case (.invalidParameters(let lhsMessage), .invalidParameters(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.tokenExpired, .tokenExpired):
            return true
        case (.invalidToken, .invalidToken):
            return true
        case (.sessionExpired, .sessionExpired):
            return true
        case (.unknown(let lhsError), .unknown(let rhsError)):
            let lhsStr = lhsError != nil ? "\(lhsError!)" : "nil"
            let rhsStr = rhsError != nil ? "\(rhsError!)" : "nil"
            return lhsStr == rhsStr
        default:
            return false
        }
    }
    
    // MARK: - Network Errors
    
    /// No internet connection
    case noInternetConnection
    
    /// The server is unreachable
    case serverUnreachable
    
    /// The request timed out
    case requestTimeout
    
    /// Invalid URL
    case invalidURL
    
    // MARK: - HTTP Status Code Errors
    
    /// 400 Bad Request
    case badRequest(message: String?)
    
    /// 401 Unauthorized
    case unauthorized(message: String?)
    
    /// 403 Forbidden
    case forbidden(message: String?)
    
    /// 404 Not Found
    case notFound(message: String?)
    
    /// 405 Method Not Allowed
    case methodNotAllowed
    
    /// 408 Request Timeout
    case requestTimeoutError
    
    /// 409 Conflict
    case conflict(message: String?)
    
    /// 422 Unprocessable Entity
    case unprocessableEntity(errors: [String: [String]]?)
    
    /// 429 Too Many Requests
    case rateLimited(retryAfter: Int?)
    
    /// 500 Internal Server Error
    case internalServerError(message: String?)
    
    /// 502 Bad Gateway
    case badGateway
    
    /// 503 Service Unavailable
    case serviceUnavailable
    
    /// 504 Gateway Timeout
    case gatewayTimeout
    
    // MARK: - Response Errors
    
    /// Failed to decode the response
    case decodingError(Error)
    
    /// The response data is invalid or empty
    case invalidResponse
    
    /// The server returned an unexpected error
    case serverError(statusCode: Int, message: String?)
    
    // MARK: - Request Errors
    
    /// Failed to encode the request body
    case encodingError(Error)
    
    /// Missing required parameters
    case missingParameters([String])
    
    /// Invalid parameters
    case invalidParameters(message: String)
    
    // MARK: - Authentication Errors
    
    /// Token expired
    case tokenExpired
    
    /// Invalid token
    case invalidToken
    
    /// Session expired
    case sessionExpired
    
    // MARK: - Unknown Error
    
    /// An unknown error occurred
    case unknown(Error?)
    
    // MARK: - Localized Error
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        
        case .serverUnreachable:
            return "Unable to connect to the server. Please try again later."
        
        case .requestTimeout:
            return "The request timed out. Please try again."
        
        case .invalidURL:
            return "Invalid request URL."
        
        case .badRequest(let message):
            return message ?? "Bad request. Please check your input."
        
        case .unauthorized(let message):
            return message ?? "Unauthorized. Please log in."
        
        case .forbidden(let message):
            return message ?? "You don't have permission to perform this action."
        
        case .notFound(let message):
            return message ?? "The requested resource was not found."
        
        case .methodNotAllowed:
            return "This request method is not allowed."
        
        case .requestTimeoutError:
            return "Request timeout. Please try again."
        
        case .conflict(let message):
            return message ?? "A conflict occurred. Please try again."
        
        case .unprocessableEntity(let errors):
            return formatValidationErrors(errors)
        
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Too many requests. Please try again in " + (retryAfter > 60 ? "1 minute" : "few seconds")
            }
            return "Too many requests. Please try again later."
        
        case .internalServerError(let message):
            return message ?? "Something went wrong on our end. Please try again later."
        
        case .badGateway:
            return "Bad gateway. Please try again."
        
        case .serviceUnavailable:
            return "Service unavailable. Please try again later."
        
        case .gatewayTimeout:
            return "Gateway timeout. Please try again."
        
        case .decodingError(let error):
            return "Failed to process response: " + error.localizedDescription
        
        case .invalidResponse:
            return "Invalid response from server."
        
        case .serverError(let statusCode, let message):
            return message ?? "Server error: " + statusCode.description
        
        case .encodingError(let error):
            return "Failed to prepare request: " + error.localizedDescription
        
        case .missingParameters(let parameters):
            return "Missing parameters: " + parameters.joined(separator: ", ")
        
        case .invalidParameters(let message):
            return message
        
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        
        case .invalidToken:
            return "Invalid session. Please log in again."
        
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        
        case .unknown(let error):
            return error?.localizedDescription ?? "An unexpected error occurred. Please try again."
        }
    }
    
    public var failureReason: String? {
        return errorDescription
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection, .serverUnreachable, .requestTimeout:
            return "Please check your network connection and try again."
        case .unauthorized, .tokenExpired, .invalidToken, .sessionExpired:
            return "Please log in to continue."
        case .rateLimited:
            return "Please wait before trying again."
        default:
            return "Please try again later."
        }
    }
    
    // MARK: - Error Code
    
    public var errorCode: Int {
        switch self {
        case .noInternetConnection: return -1009
        case .serverUnreachable: return -1001
        case .requestTimeout: return -1001
        case .invalidURL: return -1000
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .methodNotAllowed: return 405
        case .requestTimeoutError: return 408
        case .conflict: return 409
        case .unprocessableEntity: return 422
        case .rateLimited: return 429
        case .internalServerError: return 500
        case .badGateway: return 502
        case .serviceUnavailable: return 503
        case .gatewayTimeout: return 504
        case .decodingError: return -2000
        case .invalidResponse: return -2001
        case .serverError(let statusCode, _): return statusCode
        case .encodingError: return -2002
        case .missingParameters: return -2003
        case .invalidParameters: return -2004
        case .tokenExpired: return 401
        case .invalidToken: return 401
        case .sessionExpired: return 401
        case .unknown: return -9999
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Determines if this is a network-related error
    public var isNetworkError: Bool {
        switch self {
        case .noInternetConnection, .serverUnreachable, .requestTimeout, .invalidURL:
            return true
        default:
            return false
        }
    }
    
    /// Determines if this is an authentication-related error
    public var isAuthError: Bool {
        switch self {
        case .unauthorized, .tokenExpired, .invalidToken, .sessionExpired:
            return true
        default:
            return false
        }
    }
    
    /// Determines if the error should trigger a token refresh
    public var shouldRefreshToken: Bool {
        switch self {
        case .unauthorized, .tokenExpired, .invalidToken:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Static Methods
    
    /// Creates an APIError from an HTTP status code and optional message
    public static func from(statusCode: Int, message: String? = nil, errors: [String: [String]]? = nil) -> APIError {
        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized(message: message)
        case 403:
            return .forbidden(message: message)
        case 404:
            return .notFound(message: message)
        case 405:
            return .methodNotAllowed
        case 408:
            return .requestTimeoutError
        case 409:
            return .conflict(message: message)
        case 422:
            return .unprocessableEntity(errors: errors)
        case 429:
            return .rateLimited(retryAfter: nil)
        case 500:
            return .internalServerError(message: message)
        case 502:
            return .badGateway
        case 503:
            return .serviceUnavailable
        case 504:
            return .gatewayTimeout
        default:
            return .serverError(statusCode: statusCode, message: message)
        }
    }
    
    /// Creates an APIError from a URLError
    public static func from(urlError: URLError) -> APIError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .requestTimeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        case .cannotFindHost, .cannotConnectToHost:
            return .serverUnreachable
        case .serverCertificateHasUnknownRoot, .serverCertificateUntrusted:
            return .serverUnreachable
        default:
            return .unknown(urlError)
        }
    }
    
    // MARK: - Private Helpers
    
    private func formatValidationErrors(_ errors: [String: [String]]?) -> String {
        guard let errors = errors, !errors.isEmpty else {
            return "Invalid input. Please check your entries."
        }
        
        let messages: [String] = errors.compactMap { field, messages in
            guard !messages.isEmpty else { return nil }
            return "• " + messages.joined(separator: ", ")
        }
        
        return "Validation errors:\n" + messages.joined(separator: "\n")
    }
}

// MARK: - Error Extensions

public extension Error {
    /// Converts any Error to APIError
    func toAPIError() -> APIError {
        if let apiError = self as? APIError {
            return apiError
        }
        
        if let urlError = self as? URLError {
            return APIError.from(urlError: urlError)
        }
        
        return .unknown(self)
    }
}

// MARK: - ValidationError for API responses

public struct ValidationError: Codable, Error {
    public let field: String
    public let message: String
    
    public init(field: String, message: String) {
        self.field = field
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case field
        case message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        field = try container.decode(String.self, forKey: .field)
        message = try container.decode(String.self, forKey: .message)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(field, forKey: .field)
        try container.encode(message, forKey: .message)
    }
}

public struct APIErrorResponse: Codable {
    public let message: String?
    public let code: String?
    public let status: Int?
    public let errors: [String: [String]]?
    
    enum CodingKeys: String, CodingKey {
        case message
        case code
        case status
        case errors
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        code = try container.decodeIfPresent(String.self, forKey: .code)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(errors, forKey: .errors)
    }
}
