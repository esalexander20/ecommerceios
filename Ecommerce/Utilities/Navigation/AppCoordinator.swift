//
//  AppCoordinator.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import SwiftUI
import Combine

/// Main application coordinator
/// Manages the overall app navigation flow and coordinates between different features
public final class AppCoordinator: CoordinatorProtocol {
    
    // MARK: - Properties
    
    /// The router used for navigation
    public let router: RouterProtocol
    
    /// Child coordinators
    public var childCoordinators: [CoordinatorProtocol] = []
    
    /// Dependency injection container
    private let diContainer: DIContainerProtocol
    
    /// Cancellation bag for Combine publishers
    private var cancellables = Set<AnyCancellable>()
    
    /// Authentication state
    @Published public private(set) var isAuthenticated: Bool = false
    
    /// Onboarding completed state
    @Published public private(set) var isOnboardingCompleted: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the AppCoordinator
    /// - Parameter router: The router to use for navigation
    /// - Parameter diContainer: The dependency injection container
    public init(router: RouterProtocol, diContainer: DIContainerProtocol = DI.container) {
        self.router = router
        self.diContainer = diContainer
        
        // Setup authentication state observation
        setupAuthStateObservation()
    }
    
    // MARK: - Coordinator Lifecycle
    
    /// Starts the coordinator's flow
    /// This is the entry point for the app's navigation
    public func start() {
        // Check onboarding state first
        checkOnboardingState()
    }
    
    // MARK: - Authentication Flow
    
    /// Shows the authentication flow (login/signup)
    public func showAuthFlow() {
        // Reset navigation stack
        router.reset()
        
        // Navigate to login
        router.navigate(to: .login, animated: true)
    }
    
    /// Shows the main app flow after successful authentication
    public func showMainFlow() {
        // Reset navigation stack
        router.reset()
        
        // Navigate to home
        router.navigate(to: .home, animated: true)
    }
    
    /// Handles successful login
    public func didLogin() {
        isAuthenticated = true
        showMainFlow()
    }
    
    /// Handles logout
    public func didLogout() {
        isAuthenticated = false
        
        // Clear auth state
        // In future: clear tokens, user data, etc.
        
        // Show auth flow
        showAuthFlow()
    }
    
    // MARK: - Onboarding Flow
    
    /// Checks if onboarding has been completed
    private func checkOnboardingState() {
        // For now, assume onboarding is completed
        // In future: check UserDefaults or backend
        isOnboardingCompleted = true
        
        if isOnboardingCompleted {
            // Check authentication state
            if isAuthenticated {
                showMainFlow()
            } else {
                showAuthFlow()
            }
        } else {
            showOnboardingFlow()
        }
    }
    
    /// Shows the onboarding flow
    public func showOnboardingFlow() {
        router.reset()
        router.navigate(to: .onboarding, animated: true)
    }
    
    /// Handles onboarding completion
    public func didCompleteOnboarding() {
        isOnboardingCompleted = true
        
        // Save onboarding completed state
        // UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // Continue to auth flow
        if isAuthenticated {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }
    
    // MARK: - Product Discovery Flow
    
    /// Shows the product list
    public func showProducts() {
        router.navigate(to: .products, animated: true)
    }
    
    /// Shows product detail for a specific product
    /// - Parameter productId: The ID of the product to show
    public func showProductDetail(productId: String) {
        router.navigate(to: .productDetail(productId: productId), animated: true)
    }
    
    /// Shows product search
    public func showProductSearch() {
        router.navigate(to: .productSearch, animated: true)
    }
    
    /// Shows categories
    public func showCategories() {
        router.navigate(to: .categories, animated: true)
    }
    
    /// Shows products for a specific category
    /// - Parameters:
    ///   - categoryId: The ID of the category
    ///   - categoryName: The name of the category
    public func showCategoryProducts(categoryId: String, categoryName: String) {
        router.navigate(to: .categoryProducts(categoryId: categoryId, categoryName: categoryName), animated: true)
    }
    
    // MARK: - Cart Flow
    
    /// Shows the shopping cart
    public func showCart() {
        router.navigate(to: .cart, animated: true)
    }
    
    /// Shows empty cart state
    public func showCartEmpty() {
        router.navigate(to: .cartEmpty, animated: true)
    }
    
    // MARK: - Checkout Flow
    
    /// Starts the checkout flow
    public func startCheckout() {
        router.navigate(to: .checkout, animated: true)
    }
    
    /// Shows shipping address selection
    public func showShippingAddress() {
        router.navigate(to: .shippingAddress, animated: true)
    }
    
    /// Shows shipping method selection
    public func showShippingMethod() {
        router.navigate(to: .shippingMethod, animated: true)
    }
    
    /// Shows payment method selection
    public func showPaymentMethod() {
        router.navigate(to: .paymentMethod, animated: true)
    }
    
    /// Shows order summary
    public func showOrderSummary() {
        router.navigate(to: .orderSummary, animated: true)
    }
    
    /// Shows payment processing
    public func showPaymentProcessing() {
        router.navigate(to: .paymentProcessing, animated: true)
    }
    
    /// Shows order confirmation
    /// - Parameter orderId: The ID of the confirmed order
    public func showOrderConfirmation(orderId: String) {
        router.navigate(to: .orderConfirmation(orderId: orderId), animated: true)
    }
    
    /// Handles successful order placement
    /// - Parameter orderId: The ID of the placed order
    public func didPlaceOrder(orderId: String) {
        showOrderConfirmation(orderId: orderId)
    }
    
    // MARK: - Orders Flow
    
    /// Shows the orders list
    public func showOrders() {
        router.navigate(to: .orders, animated: true)
    }
    
    /// Shows order detail
    /// - Parameter orderId: The ID of the order to show
    public func showOrderDetail(orderId: String) {
        router.navigate(to: .orderDetail(orderId: orderId), animated: true)
    }
    
    /// Shows order tracking
    /// - Parameter orderId: The ID of the order to track
    public func showOrderTracking(orderId: String) {
        router.navigate(to: .orderTracking(orderId: orderId), animated: true)
    }
    
    /// Shows return request form
    /// - Parameter orderId: The ID of the order to return
    public func showReturnRequest(orderId: String) {
        router.navigate(to: .returnRequest(orderId: orderId), animated: true)
    }
    
    // MARK: - Profile Flow
    
    /// Shows the user profile
    public func showProfile() {
        router.navigate(to: .profile, animated: true)
    }
    
    /// Shows edit profile
    public func showEditProfile() {
        router.navigate(to: .editProfile, animated: true)
    }
    
    /// Shows address book
    public func showAddressBook() {
        router.navigate(to: .addressBook, animated: true)
    }
    
    /// Shows add address form
    public func showAddAddress() {
        router.navigate(to: .addAddress, animated: true)
    }
    
    /// Shows edit address form
    /// - Parameter addressId: The ID of the address to edit
    public func showEditAddress(addressId: String) {
        router.navigate(to: .editAddress(addressId: addressId), animated: true)
    }
    
    /// Shows payment methods
    public func showPaymentMethods() {
        router.navigate(to: .paymentMethods, animated: true)
    }
    
    /// Shows add payment method
    public func showAddPaymentMethod() {
        router.navigate(to: .addPaymentMethod, animated: true)
    }
    
    /// Shows notification settings
    public func showNotificationSettings() {
        router.navigate(to: .notificationSettings, animated: true)
    }
    
    /// Shows account settings
    public func showAccountSettings() {
        router.navigate(to: .accountSettings, animated: true)
    }
    
    // MARK: - Wishlist Flow
    
    /// Shows the wishlist
    public func showWishlist() {
        router.navigate(to: .wishlist, animated: true)
    }
    
    /// Shows empty wishlist state
    public func showWishlistEmpty() {
        router.navigate(to: .wishlistEmpty, animated: true)
    }
    
    // MARK: - Notifications Flow
    
    /// Shows notifications list
    public func showNotifications() {
        router.navigate(to: .notifications, animated: true)
    }
    
    /// Shows notification detail
    /// - Parameter notificationId: The ID of the notification to show
    public func showNotificationDetail(notificationId: String) {
        router.navigate(to: .notificationDetail(notificationId: notificationId), animated: true)
    }
    
    // MARK: - Settings Flow
    
    /// Shows settings
    public func showSettings() {
        router.navigate(to: .settings, animated: true)
    }
    
    /// Shows theme settings
    public func showThemeSettings() {
        router.navigate(to: .themeSettings, animated: true)
    }
    
    /// Shows language settings
    public func showLanguageSettings() {
        router.navigate(to: .languageSettings, animated: true)
    }
    
    /// Shows currency settings
    public func showCurrencySettings() {
        router.navigate(to: .currencySettings, animated: true)
    }
    
    /// Shows privacy policy
    public func showPrivacyPolicy() {
        router.navigate(to: .privacyPolicy, animated: true)
    }
    
    /// Shows terms of service
    public func showTermsOfService() {
        router.navigate(to: .termsOfService, animated: true)
    }
    
    /// Shows about page
    public func showAbout() {
        router.navigate(to: .about, animated: true)
    }
    
    /// Shows help page
    public func showHelp() {
        router.navigate(to: .help, animated: true)
    }
    
    /// Shows contact us page
    public func showContactUs() {
        router.navigate(to: .contactUs, animated: true)
    }
    
    // MARK: - Native Features
    
    /// Shows barcode scanner
    public func showBarcodeScanner() {
        router.navigate(to: .barcodeScanner, animated: true)
    }
    
    /// Shows camera
    public func showCamera() {
        router.navigate(to: .camera, animated: true)
    }
    
    /// Shows photo library
    public func showPhotoLibrary() {
        router.navigate(to: .photoLibrary, animated: true)
    }
    
    /// Shows location
    public func showLocation() {
        router.navigate(to: .location, animated: true)
    }
    
    /// Shows store locator
    public func showStoreLocator() {
        router.navigate(to: .storeLocator, animated: true)
    }
    
    // MARK: - Error Handling
    
    /// Shows an error view
    /// - Parameter message: The error message to display
    public func showError(message: String) {
        router.navigate(to: .error(message: message), animated: true)
    }
    
    /// Shows maintenance view
    public func showMaintenance() {
        router.navigate(to: .maintenance, animated: true)
    }
    
    /// Shows no internet connection view
    public func showNoInternetConnection() {
        router.navigate(to: .noInternetConnection, animated: true)
    }
    
    /// Shows coming soon view
    public func showComingSoon() {
        router.navigate(to: .comingSoon, animated: true)
    }
    
    // MARK: - Deep Links
    
    /// Handles a deep link
    /// - Parameter url: The URL to handle
    public func handleDeepLink(_ url: URL) {
        router.navigate(to: .deepLink(url: url), animated: true)
    }
    
    // MARK: - Tab Navigation
    
    /// Switches to the home tab
    public func switchToHomeTab() {
        router.navigate(to: .tabHome, animated: true)
    }
    
    /// Switches to the explore tab
    public func switchToExploreTab() {
        router.navigate(to: .tabExplore, animated: true)
    }
    
    /// Switches to the cart tab
    public func switchToCartTab() {
        router.navigate(to: .tabCart, animated: true)
    }
    
    /// Switches to the orders tab
    public func switchToOrdersTab() {
        router.navigate(to: .tabOrders, animated: true)
    }
    
    /// Switches to the profile tab
    public func switchToProfileTab() {
        router.navigate(to: .tabProfile, animated: true)
    }
    
    // MARK: - Private Methods
    
    /// Sets up observation of authentication state
    private func setupAuthStateObservation() {
        // In future: observe auth service state changes
        // For now, this is a placeholder
    }
}
