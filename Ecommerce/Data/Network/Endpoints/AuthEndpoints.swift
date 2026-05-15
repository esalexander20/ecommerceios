//
//  AuthEndpoints.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

// MARK: - Authentication Endpoints

public enum AuthEndpoint: APIEndpoint {
    case login(email: String, password: String)
    case signup(email: String, password: String, name: String, phone: String?)
    case logout
    case refreshToken(refreshToken: String)
    case forgotPassword(email: String)
    case resetPassword(token: String, newPassword: String)
    case verifyEmail(token: String)
    case resendVerificationEmail(email: String)
    case socialLogin(provider: String, token: String)
    case appleLogin(token: String, name: String?)
    case googleLogin(token: String)
    case facebookLogin(token: String)
    
    public var path: String {
        switch self {
        case .login: return "/auth/login"
        case .signup: return "/auth/signup"
        case .logout: return "/auth/logout"
        case .refreshToken: return "/auth/refresh"
        case .forgotPassword: return "/auth/forgot-password"
        case .resetPassword: return "/auth/reset-password"
        case .verifyEmail: return "/auth/verify-email"
        case .resendVerificationEmail: return "/auth/resend-verification"
        case .socialLogin: return "/auth/social-login"
        case .appleLogin: return "/auth/apple-login"
        case .googleLogin: return "/auth/google-login"
        case .facebookLogin: return "/auth/facebook-login"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login, .signup, .refreshToken, .forgotPassword, .resetPassword, .verifyEmail, .resendVerificationEmail, .socialLogin, .appleLogin, .googleLogin, .facebookLogin:
            return .post
        case .logout:
            return .post
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        default:
            return ["Accept": "application/json"]
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        
        case .signup(let email, let password, let name, let phone):
            var params: [String: Any] = [
                "email": email,
                "password": password,
                "name": name
            ]
            if let phone = phone {
                params["phone"] = phone
            }
            return params
        
        case .refreshToken(let refreshToken):
            return ["refresh_token": refreshToken]
        
        case .forgotPassword(let email):
            return ["email": email]
        
        case .resetPassword(let token, let newPassword):
            return ["token": token, "new_password": newPassword]
        
        case .verifyEmail(let token):
            return ["token": token]
        
        case .resendVerificationEmail(let email):
            return ["email": email]
        
        case .socialLogin(let provider, let token):
            return ["provider": provider, "token": token]
        
        case .appleLogin(let token, let name):
            var params: [String: Any] = ["token": token]
            if let name = name {
                params["name"] = name
            }
            return params
        
        case .googleLogin(let token):
            return ["token": token, "provider": "google"]
        
        case .facebookLogin(let token):
            return ["token": token, "provider": "facebook"]
        
        case .logout:
            return nil
        }
    }
}
