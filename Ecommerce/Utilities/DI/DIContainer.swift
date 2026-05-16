//
//  DIContainer.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import Combine
import SwiftUI

/// Main Dependency Injection Container implementation
/// Provides centralized access to all app dependencies
public final class DIContainer: DIContainerProtocol {

    // MARK: - Singleton

    public static let shared = DIContainer()

    // MARK: - Private Initialization

    private init() {
        // Initialize all lazy dependencies
        _ = apiClient
        _ = persistenceController
        _ = productRepository
    }

    // MARK: - Networking

    private lazy var _apiClient: APIClientProtocol = {
        // In production, use real API client
        // In tests, this can be replaced with MockAPIClient
        #if DEBUG
        let interceptor = LoggingInterceptor()
        return APIClient(
            session: URLSession.shared,
            baseURL: nil,
            interceptor: interceptor
        )
        #else
        return APIClient.shared
        #endif
    }()

    public var apiClient: APIClientProtocol { return _apiClient }

    // MARK: - Persistence

    private lazy var _persistenceController: PersistenceController = {
        return PersistenceController.shared
    }()

    public var persistenceController: PersistenceController { return _persistenceController }

    // MARK: - Repositories

    private lazy var _productRepository: any ProductRepositoryProtocol = {
        return ProductRepository(
            apiClient: apiClient,
            persistenceController: persistenceController
        )
    }()

    public var productRepository: any ProductRepositoryProtocol { return _productRepository }

    // Placeholder repositories - will be implemented in future steps
    private lazy var _cartRepository: any CartRepositoryProtocol = {
        // Temporary implementation - will be replaced with real implementation
        return MockCartRepository()
    }()

    public var cartRepository: any CartRepositoryProtocol { return _cartRepository }

    private lazy var _orderRepository: any OrderRepositoryProtocol = {
        return MockOrderRepository()
    }()

    public var orderRepository: any OrderRepositoryProtocol { return _orderRepository }

    private lazy var _userRepository: any UserRepositoryProtocol = {
        return MockUserRepository()
    }()

    public var userRepository: any UserRepositoryProtocol { return _userRepository }

    private lazy var _addressRepository: any AddressRepositoryProtocol = {
        return MockAddressRepository()
    }()

    public var addressRepository: any AddressRepositoryProtocol { return _addressRepository }

    private lazy var _wishlistRepository: any WishlistRepositoryProtocol = {
        return MockWishlistRepository()
    }()

    public var wishlistRepository: any WishlistRepositoryProtocol { return _wishlistRepository }

    private lazy var _reviewRepository: any ReviewRepositoryProtocol = {
        return MockReviewRepository()
    }()

    public var reviewRepository: any ReviewRepositoryProtocol { return _reviewRepository }

    private lazy var _notificationRepository: any NotificationRepositoryProtocol = {
        return MockNotificationRepository()
    }()

    public var notificationRepository: any NotificationRepositoryProtocol { return _notificationRepository }

    private lazy var _settingsRepository: any SettingsRepositoryProtocol = {
        return MockSettingsRepository()
    }()

    public var settingsRepository: any SettingsRepositoryProtocol { return _settingsRepository }

    // MARK: - Services

    private lazy var _authService: any AuthServiceProtocol = {
        // Will be implemented with Firebase Auth in Phase 2
        return MockAuthService()
    }()

    public var authService: any AuthServiceProtocol { return _authService }

    private lazy var _paymentService: any PaymentServiceProtocol = {
        // Will be implemented with Stripe in Phase 4
        return MockPaymentService()
    }()

    public var paymentService: any PaymentServiceProtocol { return _paymentService }

    private lazy var _analyticsService: any AnalyticsServiceProtocol = {
        // Will be implemented with Firebase Analytics
        return MockAnalyticsService()
    }()

    public var analyticsService: any AnalyticsServiceProtocol { return _analyticsService }

    private lazy var _notificationService: any NotificationServiceProtocol = {
        // Will be implemented with UserNotifications framework
        return MockNotificationService()
    }()

    public var notificationService: any NotificationServiceProtocol { return _notificationService }

    private lazy var _imageLoader: any ImageLoaderProtocol = {
        // Will be implemented with SDWebImageSwiftUI
        return MockImageLoader()
    }()

    public var imageLoader: any ImageLoaderProtocol { return _imageLoader }

    // MARK: - ViewModel Factory

    public func makeProductListViewModel() -> any ProductListViewModelProtocol {
        return MockProductListViewModel(
            productRepository: productRepository,
            wishlistRepository: wishlistRepository,
            analyticsService: analyticsService
        )
    }

    public func makeProductDetailViewModel(productId: String) -> any ProductDetailViewModelProtocol {
        return MockProductDetailViewModel(
            productId: productId,
            productRepository: productRepository,
            cartRepository: cartRepository,
            wishlistRepository: wishlistRepository,
            analyticsService: analyticsService
        )
    }

    public func makeCartViewModel() -> any CartViewModelProtocol {
        return MockCartViewModel(
            cartRepository: cartRepository,
            productRepository: productRepository,
            analyticsService: analyticsService
        )
    }

    public func makeAuthViewModel() -> any AuthViewModelProtocol {
        return MockAuthViewModel(
            authService: authService,
            userRepository: userRepository,
            analyticsService: analyticsService
        )
    }

    public func makeCheckoutViewModel() -> any CheckoutViewModelProtocol {
        return MockCheckoutViewModel(
            cartRepository: cartRepository,
            orderRepository: orderRepository,
            addressRepository: addressRepository,
            paymentService: paymentService,
            analyticsService: analyticsService
        )
    }
}

// MARK: - Mock Implementations (Placeholder)

/// Mock implementation of CartRepository for temporary use
private struct MockCartRepository: CartRepositoryProtocol {
    typealias Entity = Cart
    typealias Identifier = String

    func get(byId id: String) -> AnyPublisher<Cart, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func getAll(forceRefresh: Bool) -> AnyPublisher<[Cart], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func create(_ entity: Cart) -> AnyPublisher<Cart, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func update(_ entity: Cart) -> AnyPublisher<Cart, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func delete(byId id: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func deleteAll(byIds ids: [String]) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getCart(for userId: String) -> AnyPublisher<[Cart], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func addToCart(userId: String, productId: String, quantity: Int) -> AnyPublisher<Cart, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateQuantity(cartItemId: String, newQuantity: Int) -> AnyPublisher<Cart, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func removeFromCart(cartItemId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func clearCart(for userId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getCartItemCount(for userId: String) -> AnyPublisher<Int, APIError> {
        return Just(0).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of OrderRepository
private struct MockOrderRepository: OrderRepositoryProtocol {
    typealias Entity = Order
    typealias Identifier = String

    func get(byId id: String) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func getAll(forceRefresh: Bool) -> AnyPublisher<[Order], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func create(_ entity: Order) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func update(_ entity: Order) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func delete(byId id: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func deleteAll(byIds ids: [String]) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getOrders(for userId: String, status: String?, page: Int, limit: Int) -> AnyPublisher<[Order], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getOrder(byNumber orderNumber: String) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func createOrder(userId: String, items: [OrderItem], shippingAddressId: String, paymentMethod: String, shippingMethod: String, notes: String?) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func cancelOrder(orderId: String, reason: String?) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateStatus(orderId: String, newStatus: String) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateTracking(orderId: String, trackingNumber: String, carrier: String) -> AnyPublisher<Order, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }
}

/// Mock implementation of UserRepository
private struct MockUserRepository: UserRepositoryProtocol {
    typealias Entity = User
    typealias Identifier = String

    func get(byId id: String) -> AnyPublisher<User, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func getAll(forceRefresh: Bool) -> AnyPublisher<[User], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func create(_ entity: User) -> AnyPublisher<User, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func update(_ entity: User) -> AnyPublisher<User, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func delete(byId id: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func deleteAll(byIds ids: [String]) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getProfile(userId: String) -> AnyPublisher<User, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateProfile(_ profile: User) -> AnyPublisher<User, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updatePassword(userId: String, currentPassword: String, newPassword: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func uploadProfileImage(userId: String, imageData: Data) -> AnyPublisher<String, APIError> {
        return Just("").setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func requestPasswordReset(email: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func verifyPasswordResetToken(_ token: String) -> AnyPublisher<Bool, APIError> {
        return Just(false).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func resetPassword(token: String, newPassword: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of AddressRepository
private struct MockAddressRepository: AddressRepositoryProtocol {
    typealias Entity = Address
    typealias Identifier = String

    func get(byId id: String) -> AnyPublisher<Address, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func getAll(forceRefresh: Bool) -> AnyPublisher<[Address], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func create(_ entity: Address) -> AnyPublisher<Address, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func update(_ entity: Address) -> AnyPublisher<Address, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func delete(byId id: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func deleteAll(byIds ids: [String]) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getAddresses(for userId: String) -> AnyPublisher<[Address], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getDefaultShippingAddress(for userId: String) -> AnyPublisher<Address?, APIError> {
        return Just(nil).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getDefaultBillingAddress(for userId: String) -> AnyPublisher<Address?, APIError> {
        return Just(nil).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func setDefault(addressId: String, addressType: String, isDefault: Bool) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func createAddress(userId: String, _ address: Address) -> AnyPublisher<Address, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateAddress(_ address: Address) -> AnyPublisher<Address, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }
}

/// Mock implementation of WishlistRepository
private struct MockWishlistRepository: WishlistRepositoryProtocol {
    func addToWishlist(userId: String, productId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func removeFromWishlist(userId: String, productId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getWishlist(userId: String) -> AnyPublisher<[String], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func isInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, APIError> {
        return Just(false).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of ReviewRepository
private struct MockReviewRepository: ReviewRepositoryProtocol {
    func getReviews(for productId: String, page: Int, limit: Int) -> AnyPublisher<[ProductReview], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func addReview(userId: String, productId: String, rating: Int, title: String, comment: String) -> AnyPublisher<ProductReview, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func updateReview(reviewId: String, rating: Int, title: String, comment: String) -> AnyPublisher<ProductReview, APIError> {
        return Fail(error: .notFound(message: "Mock: Not implemented")).eraseToAnyPublisher()
    }

    func deleteReview(reviewId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getAverageRating(for productId: String) -> AnyPublisher<Double, APIError> {
        return Just(0.0).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of NotificationRepository
private struct MockNotificationRepository: NotificationRepositoryProtocol {
    func getNotifications(for userId: String, page: Int, limit: Int) -> AnyPublisher<[UserNotification], APIError> {
        return Just([]).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func markAsRead(notificationId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func markAllAsRead(for userId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func deleteNotification(notificationId: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getUnreadCount(for userId: String) -> AnyPublisher<Int, APIError> {
        return Just(0).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of SettingsRepository
private struct MockSettingsRepository: SettingsRepositoryProtocol {
    func getSettings(userId: String) -> AnyPublisher<UserSettings, APIError> {
        return Just(UserSettings()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func updateSettings(userId: String, _ settings: UserSettings) -> AnyPublisher<UserSettings, APIError> {
        return Just(settings).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

// MARK: - Mock Services

/// Mock implementation of AuthService
private struct MockAuthService: AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func getCurrentUser() -> AnyPublisher<UserDTO, APIError> {
        return Fail(error: .unauthorized(message: "Not logged in")).eraseToAnyPublisher()
    }
}

/// Mock implementation of PaymentService
private struct MockPaymentService: PaymentServiceProtocol {
    func processPayment(amount: Decimal, currency: String, paymentMethod: String) -> AnyPublisher<PaymentResult, APIError> {
        return Just(PaymentResult(paymentId: "mock_" + UUID().uuidString, status: "succeeded", amount: amount, currency: currency))
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}

/// Mock implementation of AnalyticsService
private struct MockAnalyticsService: AnalyticsServiceProtocol {
    func trackEvent(_ event: AnalyticsEvent) {
        print("Analytics: Tracking event - \(event.name)")
    }

    func trackScreenView(_ screen: String) {
        print("Analytics: Screen view - \(screen)")
    }
}

/// Mock implementation of NotificationService
private struct MockNotificationService: NotificationServiceProtocol {
    func requestPermission() -> AnyPublisher<Bool, APIError> {
        return Just(true).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func sendPushNotification(to token: String, title: String, body: String) -> AnyPublisher<Void, APIError> {
        return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }
}

/// Mock implementation of ImageLoader
private struct MockImageLoader: ImageLoaderProtocol {
    func loadImage(from url: URL?) -> AnyPublisher<PlatformImage?, Never> {
        return Just(nil).eraseToAnyPublisher()
    }
}

// MARK: - Mock ViewModels

/// Mock implementation of ProductListViewModel
private final class MockProductListViewModel: ProductListViewModelProtocol {
    var products: [Product] = []
    var isLoading: Bool = false
    var error: APIError? = nil

    init(productRepository: any ProductRepositoryProtocol, wishlistRepository: any WishlistRepositoryProtocol, analyticsService: any AnalyticsServiceProtocol) {}

    func fetchProducts(forceRefresh: Bool) {}
    func fetchFeaturedProducts() {}
    func searchProducts(query: String) {}
}

/// Mock implementation of ProductDetailViewModel
private final class MockProductDetailViewModel: ProductDetailViewModelProtocol {
    var product: Product? = nil
    var isLoading: Bool = false
    var error: APIError? = nil

    init(productId: String, productRepository: any ProductRepositoryProtocol, cartRepository: any CartRepositoryProtocol, wishlistRepository: any WishlistRepositoryProtocol, analyticsService: any AnalyticsServiceProtocol) {}

    func fetchProduct(productId: String) {}
    func addToCart() {}
    func toggleWishlist() {}
}

/// Mock implementation of CartViewModel
private final class MockCartViewModel: CartViewModelProtocol {
    var cartItems: [Cart] = []
    var totalAmount: NSDecimalNumber = 0
    var itemCount: Int = 0
    var isLoading: Bool = false
    var error: APIError? = nil

    init(cartRepository: any CartRepositoryProtocol, productRepository: any ProductRepositoryProtocol, analyticsService: any AnalyticsServiceProtocol) {}

    func fetchCart() {}
    func addItem(productId: String, quantity: Int) {}
    func updateQuantity(cartItemId: String, newQuantity: Int) {}
    func removeItem(cartItemId: String) {}
    func clearCart() {}
}

/// Mock implementation of AuthViewModel
private final class MockAuthViewModel: AuthViewModelProtocol {
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var error: APIError? = nil

    init(authService: any AuthServiceProtocol, userRepository: any UserRepositoryProtocol, analyticsService: any AnalyticsServiceProtocol) {}

    func login(email: String, password: String) {}
    func logout() {}
    func register(user: UserDTO) {}
}

/// Mock implementation of CheckoutViewModel
private final class MockCheckoutViewModel: CheckoutViewModelProtocol {
    var cartItems: [Cart] = []
    var subtotal: NSDecimalNumber = 0
    var tax: NSDecimalNumber = 0
    var shipping: NSDecimalNumber = 0
    var total: NSDecimalNumber = 0
    var shippingAddresses: [Address] = []
    var selectedShippingAddress: Address? = nil
    var selectedPaymentMethod: String? = nil
    var isLoading: Bool = false
    var error: APIError? = nil

    init(cartRepository: any CartRepositoryProtocol, orderRepository: any OrderRepositoryProtocol, addressRepository: any AddressRepositoryProtocol, paymentService: any PaymentServiceProtocol, analyticsService: any AnalyticsServiceProtocol) {}

    func fetchCheckoutData() {}
    func placeOrder() {}
}

// MARK: - Platform Image Typealias

/// Typealias for platform-specific image type
/// This allows the same code to work on both iOS and macOS
#if os(iOS) || os(tvOS)
public typealias PlatformImage = UIImage
#elseif os(macOS)
public typealias PlatformImage = NSImage
#endif
