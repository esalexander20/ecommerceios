//
//  UserEndpoints.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

// MARK: - User Profile Endpoints

public enum UserEndpoint: APIEndpoint {
    case getProfile
    case updateProfile(name: String?, email: String?, phone: String?)
    case updatePassword(currentPassword: String, newPassword: String)
    case updateAvatar(imageData: Data)
    
    // Addresses
    case getAddresses
    case getAddress(id: String)
    case addAddress(address: [String: Any])
    case updateAddress(id: String, address: [String: Any])
    case deleteAddress(id: String)
    case setDefaultAddress(id: String, type: String)
    
    // Notifications
    case getNotifications(page: Int, limit: Int)
    case markNotificationAsRead(id: String)
    case markAllNotificationsAsRead
    case deleteNotification(id: String)
    case updateNotificationPreferences(preferences: [String: Bool])
    
    public var path: String {
        switch self {
        case .getProfile: return "/users/me"
        case .updateProfile: return "/users/me"
        case .updatePassword: return "/users/me/password"
        case .updateAvatar: return "/users/me/avatar"
        case .getAddresses: return "/users/me/addresses"
        case .getAddress(let id): return "/users/me/addresses/\(id)"
        case .addAddress: return "/users/me/addresses"
        case .updateAddress(let id, _): return "/users/me/addresses/\(id)"
        case .deleteAddress(let id): return "/users/me/addresses/\(id)"
        case .setDefaultAddress(let id, _): return "/users/me/addresses/\(id)/default"
        case .getNotifications: return "/notifications"
        case .markNotificationAsRead(let id): return "/notifications/\(id)/read"
        case .markAllNotificationsAsRead: return "/notifications/read-all"
        case .deleteNotification(let id): return "/notifications/\(id)"
        case .updateNotificationPreferences: return "/notifications/preferences"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getProfile, .getAddresses, .getAddress, .getNotifications:
            return .get
        case .updateProfile, .updatePassword, .addAddress, .updateAddress, .setDefaultAddress, .markNotificationAsRead, .markAllNotificationsAsRead, .deleteNotification, .updateNotificationPreferences:
            return .post
        case .deleteAddress:
            return .delete
        case .updateAvatar:
            return .post
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .updateProfile(let name, let email, let phone):
            var params: [String: Any] = [:]
            if let name = name { params["name"] = name }
            if let email = email { params["email"] = email }
            if let phone = phone { params["phone"] = phone }
            return params.isEmpty ? nil : params
        
        case .updatePassword(let currentPassword, let newPassword):
            return ["current_password": currentPassword, "new_password": newPassword]
        
        case .addAddress(let address):
            return address
        
        case .updateAddress(_, let address):
            return address
        
        case .setDefaultAddress(_, let type):
            return ["type": type]
        
        case .markNotificationAsRead:
            return nil
        
        case .markAllNotificationsAsRead:
            return nil
        
        case .deleteNotification:
            return nil
        
        case .updateNotificationPreferences(let preferences):
            return preferences
        
        default:
            return nil
        }
    }
    
    public var queryParameters: [String: Any]? {
        switch self {
        case .getNotifications(let page, let limit):
            return ["page": page, "limit": limit]
        default:
            return nil
        }
    }
    
    public var body: Data? {
        switch self {
        case .updateAvatar(let imageData):
            return imageData
        default:
            return nil
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .updateAvatar:
            return ["Content-Type": "image/jpeg"]
        default:
            return nil
        }
    }
}
