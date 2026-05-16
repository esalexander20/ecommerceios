//
//  DIContainerProtocol.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import Combine

/// Protocol defining the Dependency Injection Container interface
/// This enables mocking and testing by allowing different implementations
public protocol DIContainerProtocol {
    /// Networking
    var apiClient: APIClientProtocol { get }

    /// Persistence
    var persistenceController: PersistenceController { get }

    /// Navigation
    var router: any RouterProtocol { get }
    var appCoordinator: AppCoordinator { get }

    /// Repositories
    var productRepository: any ProductRepositoryProtocol { get }
    var cartRepository: any CartRepositoryProtocol { get }
    var orderRepository: any OrderRepositoryProtocol { get }
    var userRepository: any UserRepositoryProtocol { get }
    var addressRepository: any AddressRepositoryProtocol { get }
    var wishlistRepository: any WishlistRepositoryProtocol { get }
    var reviewRepository: any ReviewRepositoryProtocol { get }
    var notificationRepository: any NotificationRepositoryProtocol { get }
    var settingsRepository: any SettingsRepositoryProtocol { get }

    /// Services (to be implemented in future steps)
    var authService: any AuthServiceProtocol { get }
    var paymentService: any PaymentServiceProtocol { get }
    var analyticsService: any AnalyticsServiceProtocol { get }
    var notificationService: any NotificationServiceProtocol { get }
    var imageLoader: any ImageLoaderProtocol { get }

    /// ViewModel Factory
    func makeProductListViewModel() -> any ProductListViewModelProtocol
    func makeProductDetailViewModel(productId: String) -> any ProductDetailViewModelProtocol
    func makeCartViewModel() -> any CartViewModelProtocol
    func makeAuthViewModel() -> any AuthViewModelProtocol
    func makeCheckoutViewModel() -> any CheckoutViewModelProtocol
}

// MARK: - Service Protocols (Placeholder for future implementation)

/// Placeholder protocol for Authentication Service
public protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<Void, APIError>
    func logout() -> AnyPublisher<Void, APIError>
    func getCurrentUser() -> AnyPublisher<UserDTO, APIError>
}

/// Placeholder protocol for Payment Service
public protocol PaymentServiceProtocol {
    func processPayment(amount: Decimal, currency: String, paymentMethod: String) -> AnyPublisher<PaymentResult, APIError>
}

/// Placeholder for payment result
public struct PaymentResult: Codable {
    public let paymentId: String
    public let status: String
    public let amount: Decimal
    public let currency: String
}

/// Placeholder protocol for Analytics Service
public protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: AnalyticsEvent)
    func trackScreenView(_ screen: String)
}

/// Placeholder for analytics events
public struct AnalyticsEvent: Codable {
    public let name: String
    public let parameters: [String: String]?
}

/// Placeholder protocol for Notification Service
public protocol NotificationServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, APIError>
    func sendPushNotification(to token: String, title: String, body: String) -> AnyPublisher<Void, APIError>
}

/// Placeholder protocol for Image Loader
public protocol ImageLoaderProtocol {
    func loadImage(from url: URL?) -> AnyPublisher<PlatformImage?, Never>
}

// MARK: - ViewModel Protocols (Placeholder for future implementation)

public protocol ProductListViewModelProtocol: ObservableObject {
    var products: [Product] { get }
    var isLoading: Bool { get }
    var error: APIError? { get }
    func fetchProducts(forceRefresh: Bool)
    func fetchFeaturedProducts()
    func searchProducts(query: String)
}

public protocol ProductDetailViewModelProtocol: ObservableObject {
    var product: Product? { get }
    var isLoading: Bool { get }
    var error: APIError? { get }
    func fetchProduct(productId: String)
    func addToCart()
    func toggleWishlist()
}

public protocol CartViewModelProtocol: ObservableObject {
    var cartItems: [Cart] { get }
    var totalAmount: NSDecimalNumber { get }
    var itemCount: Int { get }
    var isLoading: Bool { get }
    var error: APIError? { get }
    func fetchCart()
    func addItem(productId: String, quantity: Int)
    func updateQuantity(cartItemId: String, newQuantity: Int)
    func removeItem(cartItemId: String)
    func clearCart()
}

public protocol AuthViewModelProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    var isLoading: Bool { get }
    var error: APIError? { get }
    func login(email: String, password: String)
    func logout()
    func register(user: UserDTO)
}

public protocol CheckoutViewModelProtocol: ObservableObject {
    var cartItems: [Cart] { get }
    var subtotal: NSDecimalNumber { get }
    var tax: NSDecimalNumber { get }
    var shipping: NSDecimalNumber { get }
    var total: NSDecimalNumber { get }
    var shippingAddresses: [Address] { get }
    var selectedShippingAddress: Address? { get set }
    var selectedPaymentMethod: String? { get set }
    var isLoading: Bool { get }
    var error: APIError? { get }
    func fetchCheckoutData()
    func placeOrder()
}

// MARK: - DTOs for ViewModels

/// User DTO for authentication and profile
public struct UserDTO: Identifiable, Codable, Equatable {
    public let id: String
    public let email: String
    public let name: String?
    public let phone: String?
    public let profileImage: String?

    public init(id: String, email: String, name: String? = nil, phone: String? = nil, profileImage: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.profileImage = profileImage
    }
}
