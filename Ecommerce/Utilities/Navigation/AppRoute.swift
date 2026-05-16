//
//  AppRoute.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

/// Enum defining all possible navigation routes in the app
/// Each route represents a destination that can be navigated to
/// Note: All associated values must be Hashable for the enum to conform to Hashable
public enum AppRoute: Hashable {
    
    // MARK: - Authentication Routes
    case login
    case signup
    case forgotPassword
    case resetPassword(token: String)
    case verifyEmail
    case biometricAuth
    
    // MARK: - Onboarding Routes
    case onboarding
    case welcome
    
    // MARK: - Main App Routes
    case home
    case products
    case productDetail(productId: String)
    case productSearch
    case categories
    case categoryProducts(categoryId: String, categoryName: String)
    
    // MARK: - Cart Routes
    case cart
    case cartEmpty
    
    // MARK: - Checkout Routes
    case checkout
    case shippingAddress
    case shippingMethod
    case paymentMethod
    case orderSummary
    case paymentProcessing
    case orderConfirmation(orderId: String)
    
    // MARK: - Orders Routes
    case orders
    case orderDetail(orderId: String)
    case orderTracking(orderId: String)
    case returnRequest(orderId: String)
    
    // MARK: - Profile Routes
    case profile
    case editProfile
    case addressBook
    case addAddress
    case editAddress(addressId: String)
    case paymentMethods
    case addPaymentMethod
    case notificationSettings
    case accountSettings
    
    // MARK: - Wishlist Routes
    case wishlist
    case wishlistEmpty
    
    // MARK: - Notifications Routes
    case notifications
    case notificationDetail(notificationId: String)
    
    // MARK: - Settings Routes
    case settings
    case themeSettings
    case languageSettings
    case currencySettings
    case privacyPolicy
    case termsOfService
    case about
    case help
    case contactUs
    
    // MARK: - Native Features Routes
    case barcodeScanner
    case camera
    case photoLibrary
    case location
    case storeLocator
    
    // MARK: - Error & Utility Routes
    case error(message: String)
    case maintenance
    case noInternetConnection
    case comingSoon
    
    // MARK: - Deep Link Routes
    case deepLink(url: URL)
    
    // MARK: - Tab Routes
    case tabHome
    case tabExplore
    case tabCart
    case tabOrders
    case tabProfile
}

// MARK: - Identifiable Conformance for SwiftUI

extension AppRoute: Identifiable {
    public var id: String {
        switch self {
        // Authentication
        case .login: return "login"
        case .signup: return "signup"
        case .forgotPassword: return "forgotPassword"
        case .resetPassword(let token): return "resetPassword_" + token
        case .verifyEmail: return "verifyEmail"
        case .biometricAuth: return "biometricAuth"
        
        // Onboarding
        case .onboarding: return "onboarding"
        case .welcome: return "welcome"
        
        // Main App
        case .home: return "home"
        case .products: return "products"
        case .productDetail(let productId): return "productDetail_" + productId
        case .productSearch: return "productSearch"
        case .categories: return "categories"
        case .categoryProducts(let categoryId, _): return "categoryProducts_" + categoryId
        
        // Cart
        case .cart: return "cart"
        case .cartEmpty: return "cartEmpty"
        
        // Checkout
        case .checkout: return "checkout"
        case .shippingAddress: return "shippingAddress"
        case .shippingMethod: return "shippingMethod"
        case .paymentMethod: return "paymentMethod"
        case .orderSummary: return "orderSummary"
        case .paymentProcessing: return "paymentProcessing"
        case .orderConfirmation(let orderId): return "orderConfirmation_" + orderId
        
        // Orders
        case .orders: return "orders"
        case .orderDetail(let orderId): return "orderDetail_" + orderId
        case .orderTracking(let orderId): return "orderTracking_" + orderId
        case .returnRequest(let orderId): return "returnRequest_" + orderId
        
        // Profile
        case .profile: return "profile"
        case .editProfile: return "editProfile"
        case .addressBook: return "addressBook"
        case .addAddress: return "addAddress"
        case .editAddress(let addressId): return "editAddress_" + addressId
        case .paymentMethods: return "paymentMethods"
        case .addPaymentMethod: return "addPaymentMethod"
        case .notificationSettings: return "notificationSettings"
        case .accountSettings: return "accountSettings"
        
        // Wishlist
        case .wishlist: return "wishlist"
        case .wishlistEmpty: return "wishlistEmpty"
        
        // Notifications
        case .notifications: return "notifications"
        case .notificationDetail(let notificationId): return "notificationDetail_" + notificationId
        
        // Settings
        case .settings: return "settings"
        case .themeSettings: return "themeSettings"
        case .languageSettings: return "languageSettings"
        case .currencySettings: return "currencySettings"
        case .privacyPolicy: return "privacyPolicy"
        case .termsOfService: return "termsOfService"
        case .about: return "about"
        case .help: return "help"
        case .contactUs: return "contactUs"
        
        // Native Features
        case .barcodeScanner: return "barcodeScanner"
        case .camera: return "camera"
        case .photoLibrary: return "photoLibrary"
        case .location: return "location"
        case .storeLocator: return "storeLocator"
        
        // Error & Utility
        case .error(let message): return "error_" + message
        case .maintenance: return "maintenance"
        case .noInternetConnection: return "noInternetConnection"
        case .comingSoon: return "comingSoon"
        
        // Deep Link
        case .deepLink(let url): return "deepLink_" + url.absoluteString
        
        // Tabs
        case .tabHome: return "tabHome"
        case .tabExplore: return "tabExplore"
        case .tabCart: return "tabCart"
        case .tabOrders: return "tabOrders"
        case .tabProfile: return "tabProfile"
        }
    }
}
