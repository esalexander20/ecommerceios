//
//  ProductRepository.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import Combine
import CoreData

// MARK: - Product DTO for API Responses

/// Product Data Transfer Object for API responses
/// Maps to/from Core Data Product entities
public struct ProductDTO: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let productDescription: String?
    public let price: Decimal
    public let category: String?
    public let images: [String]?
    public let stockQuantity: Int
    public let rating: Double
    public let isFeatured: Bool
    public let isOnSale: Bool
    public let salePrice: Decimal?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let brand: String?
    public let sku: String?

    public init(
        id: String,
        name: String,
        productDescription: String? = nil,
        price: Decimal,
        category: String? = nil,
        images: [String]? = nil,
        stockQuantity: Int = 0,
        rating: Double = 0.0,
        isFeatured: Bool = false,
        isOnSale: Bool = false,
        salePrice: Decimal? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        brand: String? = nil,
        sku: String? = nil
    ) {
        self.id = id
        self.name = name
        self.productDescription = productDescription
        self.price = price
        self.category = category
        self.images = images
        self.stockQuantity = stockQuantity
        self.rating = rating
        self.isFeatured = isFeatured
        self.isOnSale = isOnSale
        self.salePrice = salePrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.brand = brand
        self.sku = sku
    }

    /// Creates a mutable copy of the DTO
    public func with(category: String?) -> ProductDTO {
        return ProductDTO(
            id: id,
            name: name,
            productDescription: productDescription,
            price: price,
            category: category,
            images: images,
            stockQuantity: stockQuantity,
            rating: rating,
            isFeatured: isFeatured,
            isOnSale: isOnSale,
            salePrice: salePrice,
            createdAt: createdAt,
            updatedAt: updatedAt,
            brand: brand,
            sku: sku
        )
    }

    /// Converts DTO to Core Data Product entity
    /// - Parameter context: The managed object context
    /// - Returns: Product entity
    public func toProduct(in context: NSManagedObjectContext) -> Product {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        do {
            let existingProducts = try context.fetch(request)
            if let existingProduct = existingProducts.first {
                // Update existing product
                existingProduct.name = name
                existingProduct.productDescription = productDescription
                existingProduct.price = NSDecimalNumber(decimal: price)
                existingProduct.category = category
                existingProduct.images = images
                existingProduct.stockQuantity = Int32(stockQuantity)
                existingProduct.rating = rating
                existingProduct.isFeatured = isFeatured
                existingProduct.isOnSale = isOnSale
                existingProduct.salePrice = salePrice.map { NSDecimalNumber(decimal: $0) }
                existingProduct.brand = brand
                existingProduct.sku = sku
                existingProduct.updatedAt = updatedAt ?? Date()
                if existingProduct.createdAt == nil {
                    existingProduct.createdAt = createdAt ?? Date()
                }
                return existingProduct
            }
        } catch {
            print("Error fetching existing product: $error)")
        }

        // Create new product
        return Product(
            context: context,
            id: id,
            name: name,
            price: NSDecimalNumber(decimal: price),
            category: category,
            productDescription: productDescription,
            brand: brand,
            sku: sku,
            stockQuantity: Int32(stockQuantity),
            rating: rating,
            isFeatured: isFeatured,
            isOnSale: isOnSale,
            salePrice: salePrice.map { NSDecimalNumber(decimal: $0) },
            images: images
        )
    }

    /// Creates DTO from Core Data Product entity
    /// - Parameter product: The Product entity
    /// - Returns: ProductDTO
    public static func fromProduct(_ product: Product) -> ProductDTO {
        return ProductDTO(
            id: product.id,
            name: product.name ?? "",
            productDescription: product.productDescription,
            price: product.price.decimalValue,
            category: product.category,
            images: product.images,
            stockQuantity: Int(product.stockQuantity),
            rating: product.rating,
            isFeatured: product.isFeatured,
            isOnSale: product.isOnSale,
            salePrice: product.salePrice?.decimalValue,
            createdAt: product.createdAt,
            updatedAt: product.updatedAt,
            brand: product.brand,
            sku: product.sku
        )
    }
}

// MARK: - Products Response DTO

/// API response wrapper for multiple products
public struct ProductsResponse: Codable {
    public let products: [ProductDTO]
    public let total: Int
    public let page: Int
    public let limit: Int
    public let totalPages: Int

    public init(products: [ProductDTO], total: Int, page: Int, limit: Int, totalPages: Int) {
        self.products = products
        self.total = total
        self.page = page
        self.limit = limit
        self.totalPages = totalPages
    }
}

// MARK: - Product Repository Implementation

/// Concrete implementation of ProductRepositoryProtocol
/// Implements offline-first strategy with Core Data caching
public final class ProductRepository: ProductRepositoryProtocol {

    // MARK: - Type Aliases

    public typealias Entity = Product
    public typealias Identifier = String

    // MARK: - Dependencies

    private let apiClient: APIClientProtocol
    private let persistenceController: PersistenceController

    // MARK: - Initialization

    public init(
        apiClient: APIClientProtocol = APIClient.shared,
        persistenceController: PersistenceController = .shared
    ) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }

    // MARK: - Base Repository Protocol Implementation

    public func get(byId id: String) -> AnyPublisher<Product, APIError> {
        // First, check local cache
        if let cachedProduct = getProductFromCache(byId: id) {
            // Return cached product immediately
            return Just(cachedProduct)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from remote if not in cache
        return apiClient.request(ProductEndpoint.getProduct(id: id), accessToken: nil)
            .flatMap { [weak self] (dto: ProductDTO) -> AnyPublisher<Product, APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<Product, APIError> { promise in
                    context.performAndWait {
                        do {
                            let savedProduct = dto.toProduct(in: context)
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(savedProduct))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func getAll(forceRefresh: Bool = false) -> AnyPublisher<[Product], APIError> {
        if !forceRefresh {
            // Return cached products if available
            let cachedProducts = getAllProductsFromCache()
            if !cachedProducts.isEmpty {
                return Just(cachedProducts)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            }
        }

        // Fetch from remote
        return apiClient.request(
            ProductEndpoint.getProducts(page: 1, limit: 100, category: nil, search: nil, sortBy: nil, sortOrder: nil),
            accessToken: nil
        )
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            for dto in response.products {
                                _ = dto.toProduct(in: context)
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(self.getAllProductsFromCache()))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func create(_ entity: Product) -> AnyPublisher<Product, APIError> {
        // For products, creation typically happens via API
        // This converts the local entity to DTO and sends to server
        let dto = ProductDTO.fromProduct(entity)

        let context = persistenceController.newBackgroundContext()

        return Future<Product, APIError> { promise in
            context.performAndWait {
                do {
                    let savedProduct = dto.toProduct(in: context)
                    try context.save()
                    self.persistenceController.saveContext()
                    promise(.success(savedProduct))
                } catch {
                    promise(.failure(.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func update(_ entity: Product) -> AnyPublisher<Product, APIError> {
        let context = persistenceController.newBackgroundContext()

        return Future<Product, APIError> { promise in
            context.performAndWait {
                do {
                    let request: NSFetchRequest<Product> = Product.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", entity.id)
                    request.fetchLimit = 1

                    let products = try context.fetch(request)
                    if let productToUpdate = products.first {
                        productToUpdate.name = entity.name
                        productToUpdate.productDescription = entity.productDescription
                        productToUpdate.price = entity.price
                        productToUpdate.category = entity.category
                        productToUpdate.images = entity.images
                        productToUpdate.stockQuantity = entity.stockQuantity
                        productToUpdate.rating = entity.rating
                        productToUpdate.isFeatured = entity.isFeatured
                        productToUpdate.isOnSale = entity.isOnSale
                        productToUpdate.salePrice = entity.salePrice
                        productToUpdate.brand = entity.brand
                        productToUpdate.sku = entity.sku
                        productToUpdate.updatedAt = Date()
                        try context.save()
                        self.persistenceController.saveContext()
                        if let updatedProduct = self.getProductFromCache(byId: entity.id) {
                            promise(.success(updatedProduct))
                        } else {
                            promise(.failure(.notFound(message: "Product not found after update")))
                        }
                    } else {
                        promise(.failure(.notFound(message: "Product not found")))
                    }
                } catch {
                    promise(.failure(.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func delete(byId id: String) -> AnyPublisher<Void, APIError> {
        let context = persistenceController.newBackgroundContext()

        return Future<Void, APIError> { promise in
            context.performAndWait {
                do {
                    let request: NSFetchRequest<Product> = Product.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id)

                    let products = try context.fetch(request)
                    for product in products {
                        context.delete(product)
                    }
                    try context.save()
                    self.persistenceController.saveContext()
                    promise(.success(()))
                } catch {
                    promise(.failure(.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteAll(byIds ids: [String]) -> AnyPublisher<Void, APIError> {
        let context = persistenceController.newBackgroundContext()

        return Future<Void, APIError> { promise in
            context.performAndWait {
                do {
                    for id in ids {
                        let request: NSFetchRequest<Product> = Product.fetchRequest()
                        request.predicate = NSPredicate(format: "id == %@", id)

                        do {
                            let products = try context.fetch(request)
                            for product in products {
                                context.delete(product)
                            }
                        } catch {
                            // Continue with next id
                            print("Error deleting product with id $id): $error)")
                        }
                    }
                    try context.save()
                    self.persistenceController.saveContext()
                    promise(.success(()))
                } catch {
                    promise(.failure(.unknown(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - ProductRepositoryProtocol Implementation

    public func getFeatured(limit: Int) -> AnyPublisher<[Product], APIError> {
        // Check cache first for featured products
        let cachedProducts = getFeaturedProductsFromCache(limit: limit)
        if !cachedProducts.isEmpty {
            return Just(cachedProducts)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from remote
        return apiClient.request(ProductEndpoint.getFeaturedProducts(limit: limit), accessToken: nil)
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            for dto in response.products {
                                let product = dto.toProduct(in: context)
                                product.isFeatured = true
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(self.getFeaturedProductsFromCache(limit: limit)))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func getByCategory(_ category: String, page: Int, limit: Int) -> AnyPublisher<[Product], APIError> {
        // Check cache first
        let cachedProducts = getProductsByCategoryFromCache(category: category, limit: limit)
        if !cachedProducts.isEmpty {
            return Just(cachedProducts)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from remote
        return apiClient.request(
            ProductEndpoint.getProducts(page: page, limit: limit, category: category, search: nil, sortBy: nil, sortOrder: nil),
            accessToken: nil
        )
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            for dto in response.products {
                                let updatedDTO = dto.with(category: category)
                                _ = updatedDTO.toProduct(in: context)
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(self.getProductsByCategoryFromCache(category: category, limit: limit)))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func search(query: String, page: Int, limit: Int) -> AnyPublisher<[Product], APIError> {
        // Search is typically not cached locally in the same way
        // We'll fetch from remote and cache results
        return apiClient.request(
            ProductEndpoint.getProducts(page: page, limit: limit, category: nil, search: query, sortBy: nil, sortOrder: nil),
            accessToken: nil
        )
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            var resultProducts: [Product] = []
                            for dto in response.products {
                                let product = dto.toProduct(in: context)
                                resultProducts.append(product)
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(resultProducts))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func getOnSale(page: Int, limit: Int) -> AnyPublisher<[Product], APIError> {
        // Check cache first
        let cachedProducts = getOnSaleProductsFromCache(limit: limit)
        if !cachedProducts.isEmpty {
            return Just(cachedProducts)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from remote
        return apiClient.request(ProductEndpoint.getOnSaleProducts(limit: limit), accessToken: nil)
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            for dto in response.products {
                                let product = dto.toProduct(in: context)
                                product.isOnSale = true
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(self.getOnSaleProductsFromCache(limit: limit)))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func getBySKU(_ sku: String) -> AnyPublisher<Product, APIError> {
        // Check cache first
        if let cachedProduct = getProductBySKUFromCache(sku: sku) {
            return Just(cachedProduct)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        // For now, fetch all and filter since there's no specific endpoint
        return getAll(forceRefresh: true)
            .map { products -> Product in
                products.first { $0.sku == sku } ?? products.first!
            }
            .eraseToAnyPublisher()
    }

    public func toggleWishlist(productId: String, isInWishlist: Bool) -> AnyPublisher<Void, APIError> {
        // This would interact with the wishlist API
        let endpoint = isInWishlist ? 
            ProductEndpoint.addToWishlist(productId: productId) :
            ProductEndpoint.removeFromWishlist(productId: productId)

        return apiClient.requestVoid(endpoint, accessToken: nil)
            .eraseToAnyPublisher()
    }

    public func getWishlist() -> AnyPublisher<[Product], APIError> {
        // Fetch wishlist from API
        return apiClient.request(ProductEndpoint.getWishlist(page: 1, limit: 100), accessToken: nil)
            .flatMap { [weak self] (response: ProductsResponse) -> AnyPublisher<[Product], APIError> in
                guard let self = self else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }

                let context = self.persistenceController.newBackgroundContext()

                return Future<[Product], APIError> { promise in
                    context.performAndWait {
                        do {
                            var resultProducts: [Product] = []
                            for dto in response.products {
                                let product = dto.toProduct(in: context)
                                resultProducts.append(product)
                            }
                            try context.save()
                            self.persistenceController.saveContext()
                            promise(.success(resultProducts))
                        } catch {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Cache Helper Methods

    private func getProductFromCache(byId id: String) -> Product? {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        do {
            let products = try persistenceController.container.viewContext.fetch(request)
            return products.first
        } catch {
            print("Error fetching product from cache: $error)")
            return nil
        }
    }

    private func getAllProductsFromCache() -> [Product] {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]

        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching all products from cache: $error)")
            return []
        }
    }

    private func getFeaturedProductsFromCache(limit: Int) -> [Product] {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "isFeatured == YES")
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.rating, ascending: false)]

        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching featured products from cache: $error)")
            return []
        }
    }

    private func getProductsByCategoryFromCache(category: String, limit: Int) -> [Product] {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.name, ascending: true)]

        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching products by category from cache: $error)")
            return []
        }
    }

    private func getOnSaleProductsFromCache(limit: Int) -> [Product] {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "isOnSale == YES")
        request.fetchLimit = limit
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Product.salePrice, ascending: true)]

        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching on-sale products from cache: $error)")
            return []
        }
    }

    private func getProductBySKUFromCache(sku: String) -> Product? {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "sku == %@", sku)
        request.fetchLimit = 1

        do {
            let products = try persistenceController.container.viewContext.fetch(request)
            return products.first
        } catch {
            print("Error fetching product by SKU from cache: $error)")
            return nil
        }
    }
}

// MARK: - Repository Namespace

public enum Repositories {
    public static var product: ProductRepository {
        return ProductRepository()
    }
}
