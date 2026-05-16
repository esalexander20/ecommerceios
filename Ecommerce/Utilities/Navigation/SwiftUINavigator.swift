//
//  SwiftUINavigator.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import SwiftUI
import Combine

/// SwiftUI-based router implementation
/// Uses NavigationPath for stack-based navigation and sheet/item for modal presentation
public final class SwiftUINavigator: RouterProtocol, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Navigation path for stack-based navigation
    @Published public var navigationPath = NavigationPath()
    
    /// Currently presented sheet (modal)
    @Published public var sheet: AppRoute?
    
    /// Currently presented full-screen cover
    @Published public var fullScreenCover: AppRoute?
    
    // MARK: - Singleton
    
    public static let shared = SwiftUINavigator()
    
    // MARK: - Navigation Methods
    
    /// Navigates to a view
    public func navigate(to view: AnyView, animated: Bool = true) {
        // For SwiftUI, we typically navigate using routes rather than views directly
        // This is a fallback for direct view navigation
    }
    
    /// Navigates to a route
    public func navigate(to route: AppRoute, animated: Bool = true) {
        // Skip if this is a modal route
        if isModalRoute(route) {
            presentModal(route)
            return
        }
        
        // Skip if this is a full-screen route
        if isFullScreenRoute(route) {
            presentFullScreen(route)
            return
        }
        
        // Navigate using NavigationPath
        DispatchQueue.main.async {
            self.navigationPath.append(route)
        }
    }
    
    /// Pops the top view (goes back)
    public func pop(animated: Bool = true) {
        DispatchQueue.main.async {
            if !self.navigationPath.isEmpty {
                self.navigationPath.removeLast()
            }
        }
    }
    
    /// Pops to the root view
    public func popToRoot(animated: Bool = true) {
        DispatchQueue.main.async {
            self.navigationPath.removeLast(self.navigationPath.count)
        }
    }
    
    /// Dismisses the current view/modal
    public func dismiss(animated: Bool = true) {
        DispatchQueue.main.async {
            self.sheet = nil
            self.fullScreenCover = nil
        }
    }
    
    /// Presents a view modally (as a sheet)
    public func present(_ view: AnyView, animated: Bool = true, completion: (() -> Void)? = nil) {
        // For route-based navigation
    }
    
    /// Presents a modal using a route
    public func presentModal(_ route: AppRoute) {
        DispatchQueue.main.async {
            self.sheet = route
        }
    }
    
    /// Presents a full-screen modal
    public func presentFullScreen(_ route: AppRoute) {
        DispatchQueue.main.async {
            self.fullScreenCover = route
        }
    }
    
    /// Dismisses a modal view
    public func dismissModal(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated)
        completion?()
    }
    
    /// Resets the navigation stack
    public func reset() {
        DispatchQueue.main.async {
            self.navigationPath.removeLast(self.navigationPath.count)
            self.sheet = nil
            self.fullScreenCover = nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a route should be presented as a modal sheet
    private func isModalRoute(_ route: AppRoute) -> Bool {
        switch route {
        case .productDetail,
             .editProfile,
             .addAddress,
             .editAddress,
             .addPaymentMethod,
             .notificationSettings,
             .accountSettings,
             .settings,
             .notificationDetail,
             .orderDetail,
             .orderTracking,
             .returnRequest,
             .categoryProducts,
             .barcodeScanner,
             .camera,
             .photoLibrary,
             .location,
             .storeLocator:
            return true
        default:
            return false
        }
    }
    
    /// Checks if a route should be presented as a full-screen modal
    private func isFullScreenRoute(_ route: AppRoute) -> Bool {
        switch route {
        case .login,
             .signup,
             .forgotPassword,
             .resetPassword,
             .checkout,
             .shippingAddress,
             .shippingMethod,
             .paymentMethod,
             .orderSummary,
             .paymentProcessing,
             .orderConfirmation,
             .addressBook,
             .paymentMethods:
            return true
        default:
            return false
        }
    }
    
    // MARK: - View Builders
    
    /// Builds a view for a given route
    @ViewBuilder
    public func view(for route: AppRoute) -> some View {
        switch route {
        // Authentication
        case .login:
            // Will be implemented in Phase 2
            Text("Login View")
        case .signup:
            Text("Signup View")
        case .forgotPassword:
            Text("Forgot Password View")
        case .resetPassword(let token):
            Text("Reset Password View: \(token)")
        case .verifyEmail:
            Text("Verify Email View")
        case .biometricAuth:
            Text("Biometric Auth View")
        
        // Onboarding
        case .onboarding:
            Text("Onboarding View")
        case .welcome:
            Text("Welcome View")
        
        // Main App
        case .home:
            Text("Home View")
        case .products:
            Text("Products View")
        case .productDetail(let productId):
            Text("Product Detail: \(productId)")
        case .productSearch:
            Text("Product Search View")
        case .categories:
            Text("Categories View")
        case .categoryProducts(let categoryId, let categoryName):
            Text("Category Products: \(categoryName) (\(categoryId))")
        
        // Cart
        case .cart:
            Text("Cart View")
        case .cartEmpty:
            Text("Cart Empty View")
        
        // Checkout
        case .checkout:
            Text("Checkout View")
        case .shippingAddress:
            Text("Shipping Address View")
        case .shippingMethod:
            Text("Shipping Method View")
        case .paymentMethod:
            Text("Payment Method View")
        case .orderSummary:
            Text("Order Summary View")
        case .paymentProcessing:
            Text("Payment Processing View")
        case .orderConfirmation(let orderId):
            Text("Order Confirmation: \(orderId)")
        
        // Orders
        case .orders:
            Text("Orders View")
        case .orderDetail(let orderId):
            Text("Order Detail: \(orderId)")
        case .orderTracking(let orderId):
            Text("Order Tracking: \(orderId)")
        case .returnRequest(let orderId):
            Text("Return Request: \(orderId)")
        
        // Profile
        case .profile:
            Text("Profile View")
        case .editProfile:
            Text("Edit Profile View")
        case .addressBook:
            Text("Address Book View")
        case .addAddress:
            Text("Add Address View")
        case .editAddress(let addressId):
            Text("Edit Address: \(addressId)")
        case .paymentMethods:
            Text("Payment Methods View")
        case .addPaymentMethod:
            Text("Add Payment Method View")
        case .notificationSettings:
            Text("Notification Settings View")
        case .accountSettings:
            Text("Account Settings View")
        
        // Wishlist
        case .wishlist:
            Text("Wishlist View")
        case .wishlistEmpty:
            Text("Wishlist Empty View")
        
        // Notifications
        case .notifications:
            Text("Notifications View")
        case .notificationDetail(let notificationId):
            Text("Notification Detail: \(notificationId)")
        
        // Settings
        case .settings:
            Text("Settings View")
        case .themeSettings:
            Text("Theme Settings View")
        case .languageSettings:
            Text("Language Settings View")
        case .currencySettings:
            Text("Currency Settings View")
        case .privacyPolicy:
            Text("Privacy Policy View")
        case .termsOfService:
            Text("Terms of Service View")
        case .about:
            Text("About View")
        case .help:
            Text("Help View")
        case .contactUs:
            Text("Contact Us View")
        
        // Native Features
        case .barcodeScanner:
            Text("Barcode Scanner View")
        case .camera:
            Text("Camera View")
        case .photoLibrary:
            Text("Photo Library View")
        case .location:
            Text("Location View")
        case .storeLocator:
            Text("Store Locator View")
        
        // Error & Utility
        case .error(let message):
            Text("Error: \(message)")
        case .maintenance:
            Text("Maintenance View")
        case .noInternetConnection:
            Text("No Internet Connection View")
        case .comingSoon:
            Text("Coming Soon View")
        
        // Deep Link
        case .deepLink(let url):
            Text("Deep Link: \(url.absoluteString)")
        
        // Tabs
        case .tabHome:
            Text("Home Tab")
        case .tabExplore:
            Text("Explore Tab")
        case .tabCart:
            Text("Cart Tab")
        case .tabOrders:
            Text("Orders Tab")
        case .tabProfile:
            Text("Profile Tab")
        }
    }
}
