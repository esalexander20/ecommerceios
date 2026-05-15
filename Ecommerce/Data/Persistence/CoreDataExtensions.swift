//
//  CoreDataExtensions.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import CoreData

// MARK: - Product Extensions

extension Product {
    /// Convenience initializer for creating Product entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: Product unique identifier
    ///   - name: Product name
    ///   - price: Product price
    ///   - category: Product category
    ///   - description: Product description
    ///   - brand: Product brand
    ///   - sku: Product SKU
    ///   - stockQuantity: Available stock quantity
    ///   - rating: Product rating (0-5)
    ///   - isFeatured: Whether product is featured
    ///   - isOnSale: Whether product is on sale
    ///   - salePrice: Sale price (if on sale)
    ///   - images: Array of image URLs
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        name: String,
        price: NSDecimalNumber,
        category: String? = nil,
        productDescription: String? = nil,
        brand: String? = nil,
        sku: String? = nil,
        stockQuantity: Int32 = 0,
        rating: Double = 0.0,
        isFeatured: Bool = false,
        isOnSale: Bool = false,
        salePrice: NSDecimalNumber? = nil,
        images: [String]? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.price = price
        self.category = category
        self.productDescription = productDescription
        self.brand = brand
        self.sku = sku
        self.stockQuantity = stockQuantity
        self.rating = rating
        self.isFeatured = isFeatured
        self.isOnSale = isOnSale
        self.salePrice = salePrice
        self.images = images
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Formatted price string
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: price) ?? "$ \(price)"
    }

    /// Display price considering sale
    var displayPrice: String {
        if isOnSale, let salePrice = salePrice {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            let originalPriceString = formatter.string(from: price) ?? "$ \(price)"
            let salePriceString = formatter.string(from: salePrice) ?? "$ \(salePrice)"
            return "\(salePriceString) (was \(originalPriceString))"
        }
        return formattedPrice
    }
}

// MARK: - Cart Extensions

extension Cart {
    /// Convenience initializer for creating Cart entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: Cart item unique identifier
    ///   - userId: User identifier
    ///   - productId: Product identifier
    ///   - quantity: Item quantity
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        userId: String,
        productId: String,
        quantity: Int32 = 1
    ) {
        self.init(context: context)
        self.id = id
        self.userId = userId
        self.productId = productId
        self.quantity = quantity
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Calculated total price (requires fetching product)
    func totalPrice(in context: NSManagedObjectContext) -> NSDecimalNumber? {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", productId)
        request.fetchLimit = 1

        do {
            let products = try context.fetch(request)
            if let product = products.first {
                let quantityDecimal = NSDecimalNumber(value: Int(quantity))
                return product.price.multiplying(by: quantityDecimal)
            }
        } catch {
            print("Error fetching product for cart item: \(error)")
        }
        return nil
    }
}

// MARK: - Order Extensions

extension Order {
    /// Convenience initializer for creating Order entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: Order unique identifier
    ///   - userId: User identifier
    ///   - orderNumber: Order number for display
    ///   - totalAmount: Total order amount
    ///   - status: Order status
    ///   - paymentMethod: Payment method used
    ///   - paymentStatus: Payment status
    ///   - shippingMethod: Shipping method
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        userId: String,
        orderNumber: String,
        totalAmount: NSDecimalNumber,
        status: String,
        paymentMethod: String? = nil,
        paymentStatus: String? = nil,
        shippingMethod: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.userId = userId
        self.orderNumber = orderNumber
        self.totalAmount = totalAmount
        self.status = status
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.shippingMethod = shippingMethod
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Order status as enum for type safety
    enum Status: String {
        case pending = "pending"
        case processing = "processing"
        case shipped = "shipped"
        case delivered = "delivered"
        case cancelled = "cancelled"
        case refunded = "refunded"
    }

    /// Payment status as enum
    enum PaymentStatus: String {
        case pending = "pending"
        case paid = "paid"
        case failed = "failed"
        case refunded = "refunded"
    }
}

// MARK: - OrderItem Extensions

extension OrderItem {
    /// Convenience initializer for creating OrderItem entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: Order item unique identifier
    ///   - orderId: Parent order identifier
    ///   - productId: Product identifier
    ///   - quantity: Item quantity
    ///   - price: Unit price at time of order
    ///   - productName: Product name snapshot
    ///   - productImage: Product image URL snapshot
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        orderId: String,
        productId: String,
        quantity: Int32,
        price: NSDecimalNumber,
        productName: String? = nil,
        productImage: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.orderId = orderId
        self.productId = productId
        self.quantity = quantity
        self.price = price
        self.productName = productName
        self.productImage = productImage
    }

    /// Calculated total for this order item
    var total: NSDecimalNumber {
        let quantityDecimal = NSDecimalNumber(value: Int(quantity))
        return price.multiplying(by: quantityDecimal)
    }
}

// MARK: - User Extensions

extension User {
    /// Convenience initializer for creating User entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: User unique identifier
    ///   - name: User full name
    ///   - email: User email address
    ///   - phone: User phone number
    ///   - profileImage: Profile image URL
    ///   - dateOfBirth: Date of birth
    ///   - gender: User gender
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        profileImage: String? = nil,
        dateOfBirth: Date? = nil,
        gender: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.profileImage = profileImage
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastLoginAt = Date()
    }
}

// MARK: - Address Extensions

extension Address {
    /// Convenience initializer for creating Address entities
    /// - Parameters:
    ///   - context: The managed object context
    ///   - id: Address unique identifier
    ///   - userId: User identifier
    ///   - fullName: Recipient full name
    ///   - phoneNumber: Contact phone number
    ///   - street: Street address
    ///   - city: City
    ///   - state: State/Province
    ///   - zipCode: Postal/ZIP code
    ///   - country: Country
    ///   - isDefault: Whether this is the default address
    ///   - addressType: Type of address (shipping, billing, etc.)
    convenience init(
        context: NSManagedObjectContext,
        id: String,
        userId: String,
        fullName: String? = nil,
        phoneNumber: String? = nil,
        street: String,
        city: String,
        state: String? = nil,
        zipCode: String? = nil,
        country: String = "USA",
        isDefault: Bool = false,
        addressType: String? = nil
    ) {
        self.init(context: context)
        self.id = id
        self.userId = userId
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.isDefault = isDefault
        self.addressType = addressType
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Formatted address string
    var formattedAddress: String {
        var parts: [String] = []
        if let fullName = fullName {
            parts.append(fullName)
        }
        parts.append(street)
        parts.append(city)
        if let state = state {
            parts.append(state)
        }
        if let zipCode = zipCode {
            parts.append(zipCode)
        }
        parts.append(country)
        return parts.joined(separator: ", ")
    }
}


