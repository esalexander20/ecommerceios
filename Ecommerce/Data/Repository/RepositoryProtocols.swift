//
//  RepositoryProtocols.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import Combine

// MARK: - Base Repository Protocol

/// Base protocol defining common CRUD operations for all repositories
public protocol RepositoryProtocol {
    /// Entity type this repository manages
    associatedtype Entity: Identifiable
    
    /// Identifier type for entities
    associatedtype Identifier = String
    
    /// Fetches a single entity by its identifier
    /// - Parameter id: The entity identifier
    /// - Returns: Publisher emitting the entity or an error
    func get(byId id: Identifier) -> AnyPublisher<Entity, APIError>
    
    /// Fetches all entities
    /// - Parameter forceRefresh: If true, bypasses cache and fetches from remote
    /// - Returns: Publisher emitting array of entities or an error
    func getAll(forceRefresh: Bool) -> AnyPublisher<[Entity], APIError>
    
    /// Creates a new entity
    /// - Parameter entity: The entity to create
    /// - Returns: Publisher emitting the created entity or an error
    func create(_ entity: Entity) -> AnyPublisher<Entity, APIError>
    
    /// Updates an existing entity
    /// - Parameter entity: The entity to update
    /// - Returns: Publisher emitting the updated entity or an error
    func update(_ entity: Entity) -> AnyPublisher<Entity, APIError>
    
    /// Deletes an entity by its identifier
    /// - Parameter id: The entity identifier
    /// - Returns: Publisher emitting success or an error
    func delete(byId id: Identifier) -> AnyPublisher<Void, APIError>
    
    /// Deletes multiple entities
    /// - Parameter ids: Array of entity identifiers
    /// - Returns: Publisher emitting success or an error
    func deleteAll(byIds ids: [Identifier]) -> AnyPublisher<Void, APIError>
}

// MARK: - Product Repository Protocol

/// Protocol for Product-specific repository operations
public protocol ProductRepositoryProtocol: RepositoryProtocol where Entity == Product {
    /// Fetches featured products
    /// - Parameter limit: Maximum number of featured products to return
    /// - Returns: Publisher emitting array of featured products
    func getFeatured(limit: Int) -> AnyPublisher<[Product], APIError>
    
    /// Fetches products by category
    /// - Parameters:
    ///   - category: The category to filter by
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of products in the category
    func getByCategory(_ category: String, page: Int, limit: Int) -> AnyPublisher<[Product], APIError>
    
    /// Searches for products
    /// - Parameters:
    ///   - query: Search query string
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of matching products
    func search(query: String, page: Int, limit: Int) -> AnyPublisher<[Product], APIError>
    
    /// Fetches products on sale
    /// - Parameters:
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of products on sale
    func getOnSale(page: Int, limit: Int) -> AnyPublisher<[Product], APIError>
    
    /// Fetches product by SKU
    /// - Parameter sku: The product SKU
    /// - Returns: Publisher emitting the product or an error
    func getBySKU(_ sku: String) -> AnyPublisher<Product, APIError>
    
    /// Toggles product in wishlist
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - isInWishlist: Whether to add or remove from wishlist
    /// - Returns: Publisher emitting success or an error
    func toggleWishlist(productId: String, isInWishlist: Bool) -> AnyPublisher<Void, APIError>
    
    /// Gets wishlist products
    /// - Returns: Publisher emitting array of wishlist products
    func getWishlist() -> AnyPublisher<[Product], APIError>
}

// MARK: - Cart Repository Protocol

/// Protocol for Cart-specific repository operations
public protocol CartRepositoryProtocol: RepositoryProtocol where Entity == Cart {
    /// Gets cart items for a specific user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting array of cart items
    func getCart(for userId: String) -> AnyPublisher<[Cart], APIError>
    
    /// Adds a product to cart
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - productId: The product identifier
    ///   - quantity: The quantity to add
    /// - Returns: Publisher emitting the updated cart or an error
    func addToCart(userId: String, productId: String, quantity: Int) -> AnyPublisher<Cart, APIError>
    
    /// Updates cart item quantity
    /// - Parameters:
    ///   - cartItemId: The cart item identifier
    ///   - newQuantity: The new quantity
    /// - Returns: Publisher emitting the updated cart item or an error
    func updateQuantity(cartItemId: String, newQuantity: Int) -> AnyPublisher<Cart, APIError>
    
    /// Removes a product from cart
    /// - Parameters:
    ///   - cartItemId: The cart item identifier
    /// - Returns: Publisher emitting success or an error
    func removeFromCart(cartItemId: String) -> AnyPublisher<Void, APIError>
    
    /// Clears all items from cart for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting success or an error
    func clearCart(for userId: String) -> AnyPublisher<Void, APIError>
    
    /// Gets cart item count for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting the count of cart items
    func getCartItemCount(for userId: String) -> AnyPublisher<Int, APIError>
}

// MARK: - Order Repository Protocol

/// Protocol for Order-specific repository operations
public protocol OrderRepositoryProtocol: RepositoryProtocol where Entity == Order {
    /// Gets orders for a specific user
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - status: Optional filter by order status
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of orders
    func getOrders(for userId: String, status: String?, page: Int, limit: Int) -> AnyPublisher<[Order], APIError>
    
    /// Gets order by order number
    /// - Parameter orderNumber: The order number
    /// - Returns: Publisher emitting the order or an error
    func getOrder(byNumber orderNumber: String) -> AnyPublisher<Order, APIError>
    
    /// Creates a new order
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - items: Array of order items
    ///   - shippingAddressId: The shipping address identifier
    ///   - paymentMethod: The payment method
    ///   - shippingMethod: The shipping method
    ///   - notes: Optional order notes
    /// - Returns: Publisher emitting the created order or an error
    func createOrder(
        userId: String,
        items: [OrderItem],
        shippingAddressId: String,
        paymentMethod: String,
        shippingMethod: String,
        notes: String?
    ) -> AnyPublisher<Order, APIError>
    
    /// Cancels an order
    /// - Parameters:
    ///   - orderId: The order identifier
    ///   - reason: Optional cancellation reason
    /// - Returns: Publisher emitting the updated order or an error
    func cancelOrder(orderId: String, reason: String?) -> AnyPublisher<Order, APIError>
    
    /// Updates order status
    /// - Parameters:
    ///   - orderId: The order identifier
    ///   - newStatus: The new status
    /// - Returns: Publisher emitting the updated order or an error
    func updateStatus(orderId: String, newStatus: String) -> AnyPublisher<Order, APIError>
    
    /// Tracks order shipment
    /// - Parameters:
    ///   - orderId: The order identifier
    ///   - trackingNumber: The tracking number
    ///   - carrier: The shipping carrier
    /// - Returns: Publisher emitting the updated order or an error
    func updateTracking(orderId: String, trackingNumber: String, carrier: String) -> AnyPublisher<Order, APIError>
}

// MARK: - User Repository Protocol

/// Protocol for User-specific repository operations
public protocol UserRepositoryProtocol: RepositoryProtocol where Entity == User {
    /// Gets current user profile
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting the user profile or an error
    func getProfile(userId: String) -> AnyPublisher<User, APIError>
    
    /// Updates user profile
    /// - Parameter profile: The updated profile data
    /// - Returns: Publisher emitting the updated user or an error
    func updateProfile(_ profile: User) -> AnyPublisher<User, APIError>
    
    /// Updates user password
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - currentPassword: Current password
    ///   - newPassword: New password
    /// - Returns: Publisher emitting success or an error
    func updatePassword(userId: String, currentPassword: String, newPassword: String) -> AnyPublisher<Void, APIError>
    
    /// Uploads profile image
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - imageData: The image data to upload
    /// - Returns: Publisher emitting the image URL or an error
    func uploadProfileImage(userId: String, imageData: Data) -> AnyPublisher<String, APIError>
    
    /// Requests password reset
    /// - Parameter email: The user's email address
    /// - Returns: Publisher emitting success or an error
    func requestPasswordReset(email: String) -> AnyPublisher<Void, APIError>
    
    /// Verifies password reset token
    /// - Parameters:
    ///   - token: The reset token
    /// - Returns: Publisher emitting whether the token is valid
    func verifyPasswordResetToken(_ token: String) -> AnyPublisher<Bool, APIError>
    
    /// Resets password with token
    /// - Parameters:
    ///   - token: The reset token
    ///   - newPassword: The new password
    /// - Returns: Publisher emitting success or an error
    func resetPassword(token: String, newPassword: String) -> AnyPublisher<Void, APIError>
}

// MARK: - Address Repository Protocol

/// Protocol for Address-specific repository operations
public protocol AddressRepositoryProtocol: RepositoryProtocol where Entity == Address {
    /// Gets addresses for a specific user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting array of addresses
    func getAddresses(for userId: String) -> AnyPublisher<[Address], APIError>
    
    /// Gets default shipping address for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting the default address or nil
    func getDefaultShippingAddress(for userId: String) -> AnyPublisher<Address?, APIError>
    
    /// Gets default billing address for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting the default address or nil
    func getDefaultBillingAddress(for userId: String) -> AnyPublisher<Address?, APIError>
    
    /// Sets default address
    /// - Parameters:
    ///   - addressId: The address identifier
    ///   - addressType: The address type (shipping or billing)
    ///   - isDefault: Whether to set as default
    /// - Returns: Publisher emitting success or an error
    func setDefault(addressId: String, addressType: String, isDefault: Bool) -> AnyPublisher<Void, APIError>
    
    /// Creates a new address
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - address: The address to create
    /// - Returns: Publisher emitting the created address or an error
    func createAddress(userId: String, _ address: Address) -> AnyPublisher<Address, APIError>
    
    /// Updates an existing address
    /// - Parameter address: The address to update
    /// - Returns: Publisher emitting the updated address or an error
    func updateAddress(_ address: Address) -> AnyPublisher<Address, APIError>
}

// MARK: - Wishlist Repository Protocol

/// Protocol for Wishlist-specific operations
public protocol WishlistRepositoryProtocol {
    /// Adds product to wishlist
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - productId: The product identifier
    /// - Returns: Publisher emitting success or an error
    func addToWishlist(userId: String, productId: String) -> AnyPublisher<Void, APIError>
    
    /// Removes product from wishlist
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - productId: The product identifier
    /// - Returns: Publisher emitting success or an error
    func removeFromWishlist(userId: String, productId: String) -> AnyPublisher<Void, APIError>
    
    /// Gets wishlist for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting array of wishlist product IDs
    func getWishlist(userId: String) -> AnyPublisher<[String], APIError>
    
    /// Checks if product is in wishlist
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - productId: The product identifier
    /// - Returns: Publisher emitting whether the product is in wishlist
    func isInWishlist(userId: String, productId: String) -> AnyPublisher<Bool, APIError>
}

// MARK: - Review Repository Protocol

/// Protocol for Product Review operations
public protocol ReviewRepositoryProtocol {
    /// Gets reviews for a product
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of reviews
    func getReviews(for productId: String, page: Int, limit: Int) -> AnyPublisher<[ProductReview], APIError>
    
    /// Adds a product review
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - productId: The product identifier
    ///   - rating: The rating (1-5)
    ///   - title: Review title
    ///   - comment: Review comment
    /// - Returns: Publisher emitting the created review or an error
    func addReview(userId: String, productId: String, rating: Int, title: String, comment: String) -> AnyPublisher<ProductReview, APIError>
    
    /// Updates a product review
    /// - Parameters:
    ///   - reviewId: The review identifier
    ///   - rating: The updated rating
    ///   - title: Updated title
    ///   - comment: Updated comment
    /// - Returns: Publisher emitting the updated review or an error
    func updateReview(reviewId: String, rating: Int, title: String, comment: String) -> AnyPublisher<ProductReview, APIError>
    
    /// Deletes a product review
    /// - Parameter reviewId: The review identifier
    /// - Returns: Publisher emitting success or an error
    func deleteReview(reviewId: String) -> AnyPublisher<Void, APIError>
    
    /// Gets average rating for a product
    /// - Parameter productId: The product identifier
    /// - Returns: Publisher emitting the average rating
    func getAverageRating(for productId: String) -> AnyPublisher<Double, APIError>
}

// MARK: - Notification Repository Protocol

/// Protocol for Notification operations
public protocol NotificationRepositoryProtocol {
    /// Gets notifications for a user
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - page: Page number for pagination
    ///   - limit: Number of items per page
    /// - Returns: Publisher emitting array of notifications
    func getNotifications(for userId: String, page: Int, limit: Int) -> AnyPublisher<[UserNotification], APIError>
    
    /// Marks notification as read
    /// - Parameter notificationId: The notification identifier
    /// - Returns: Publisher emitting success or an error
    func markAsRead(notificationId: String) -> AnyPublisher<Void, APIError>
    
    /// Marks all notifications as read
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting success or an error
    func markAllAsRead(for userId: String) -> AnyPublisher<Void, APIError>
    
    /// Deletes a notification
    /// - Parameter notificationId: The notification identifier
    /// - Returns: Publisher emitting success or an error
    func deleteNotification(notificationId: String) -> AnyPublisher<Void, APIError>
    
    /// Gets unread notification count
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting the count of unread notifications
    func getUnreadCount(for userId: String) -> AnyPublisher<Int, APIError>
}

// MARK: - Settings Repository Protocol

/// Protocol for Settings operations
public protocol SettingsRepositoryProtocol {
    /// Gets user settings
    /// - Parameter userId: The user identifier
    /// - Returns: Publisher emitting user settings or an error
    func getSettings(userId: String) -> AnyPublisher<UserSettings, APIError>
    
    /// Updates user settings
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - settings: The settings to update
    /// - Returns: Publisher emitting the updated settings or an error
    func updateSettings(userId: String, _ settings: UserSettings) -> AnyPublisher<UserSettings, APIError>
}

// MARK: - Data Transfer Objects (DTOs)

/// Product Review DTO
public struct ProductReview: Identifiable, Codable, Equatable {
    public let id: String
    public let userId: String
    public let productId: String
    public let rating: Int
    public let title: String
    public let comment: String
    public let createdAt: Date
    public let updatedAt: Date?
    
    public init(id: String, userId: String, productId: String, rating: Int, title: String, comment: String, createdAt: Date, updatedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.productId = productId
        self.rating = rating
        self.title = title
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// User Notification DTO
public struct UserNotification: Identifiable, Codable, Equatable {
    public let id: String
    public let userId: String
    public let title: String
    public let body: String
    public let type: NotificationType
    public let data: [String: String]?
    public let isRead: Bool
    public let createdAt: Date
    
    public enum NotificationType: String, Codable {
        case orderStatus
        case promotion
        case newProduct
        case priceDrop
        case abandonedCart
        case general
    }
    
    public init(id: String, userId: String, title: String, body: String, type: NotificationType, data: [String: String]? = nil, isRead: Bool = false, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.type = type
        self.data = data
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

/// User Settings DTO
public struct UserSettings: Codable, Equatable {
    public var theme: Theme
    public var language: String
    public var currency: String
    public var notificationsEnabled: Bool
    public var emailNotifications: Bool
    public var pushNotifications: Bool
    public var newsletterSubscribed: Bool
    
    public enum Theme: String, Codable {
        case system
        case light
        case dark
    }
    
    public init(
        theme: Theme = .system,
        language: String = "en",
        currency: String = "USD",
        notificationsEnabled: Bool = true,
        emailNotifications: Bool = true,
        pushNotifications: Bool = true,
        newsletterSubscribed: Bool = false
    ) {
        self.theme = theme
        self.language = language
        self.currency = currency
        self.notificationsEnabled = notificationsEnabled
        self.emailNotifications = emailNotifications
        self.pushNotifications = pushNotifications
        self.newsletterSubscribed = newsletterSubscribed
    }
}
