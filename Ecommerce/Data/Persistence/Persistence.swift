//
//  Persistence.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import CoreData

/// Manages Core Data persistence layer for the e-commerce application
public final class PersistenceController {
    
    // MARK: - Shared Instance
    
    public static let shared = PersistenceController()

    // MARK: - Preview Instance

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Load preview data
        loadPreviewData(into: viewContext)

        do {
            try viewContext.save()
        } catch {
            // Preview data loading failed - this is non-fatal for previews
            let nsError = error as NSError
            print("Preview data error: \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    // MARK: - Preview Data Helper

    private static func loadPreviewData(into context: NSManagedObjectContext) {
        // Create sample products
        let product1 = Product(context: context)
        product1.id = "prod_001"
        product1.name = "Wireless Bluetooth Headphones"
        product1.price = NSDecimalNumber(value: 99.99)
        product1.category = "Electronics"
        product1.productDescription = "High-quality wireless headphones with noise cancellation and 30-hour battery life."
        product1.brand = "SoundMax"
        product1.sku = "SM-WBH-001"
        product1.stockQuantity = 50
        product1.rating = 4.8
        product1.isFeatured = true
        product1.isOnSale = true
        product1.salePrice = NSDecimalNumber(value: 79.99)
        product1.images = [
            "https://example.com/products/headphones-1.jpg",
            "https://example.com/products/headphones-2.jpg"
        ]
        product1.createdAt = Date()
        product1.updatedAt = Date()

        let product2 = Product(context: context)
        product2.id = "prod_002"
        product2.name = "Stainless Steel Water Bottle"
        product2.price = NSDecimalNumber(value: 24.99)
        product2.category = "Home & Kitchen"
        product2.productDescription = "Insulated water bottle that keeps drinks cold for 24 hours or hot for 12 hours."
        product2.brand = "HydroFlask"
        product2.sku = "HF-SB-001"
        product2.stockQuantity = 100
        product2.rating = 4.6
        product2.isFeatured = true
        product2.isOnSale = false
        product2.images = [
            "https://example.com/products/bottle-1.jpg",
            "https://example.com/products/bottle-2.jpg"
        ]
        product2.createdAt = Date()
        product2.updatedAt = Date()

        let product3 = Product(context: context)
        product3.id = "prod_003"
        product3.name = "Organic Cotton T-Shirt"
        product3.price = NSDecimalNumber(value: 29.99)
        product3.category = "Clothing"
        product3.productDescription = "100% organic cotton unisex t-shirt. Comfortable, breathable, and eco-friendly."
        product3.brand = "EcoWear"
        product3.sku = "EW-TS-001"
        product3.stockQuantity = 75
        product3.rating = 4.4
        product3.isFeatured = false
        product3.isOnSale = true
        product3.salePrice = NSDecimalNumber(value: 19.99)
        product3.images = [
            "https://example.com/products/tshirt-1.jpg",
            "https://example.com/products/tshirt-2.jpg"
        ]
        product3.createdAt = Date()
        product3.updatedAt = Date()

        let product4 = Product(context: context)
        product4.id = "prod_004"
        product4.name = "Smart Watch Pro"
        product4.price = NSDecimalNumber(value: 299.99)
        product4.category = "Electronics"
        product4.productDescription = "Advanced smartwatch with heart rate monitoring, GPS, and 7-day battery life."
        product4.brand = "TechWear"
        product4.sku = "TW-SW-001"
        product4.stockQuantity = 25
        product4.rating = 4.9
        product4.isFeatured = true
        product4.isOnSale = false
        product4.images = [
            "https://example.com/products/smartwatch-1.jpg",
            "https://example.com/products/smartwatch-2.jpg"
        ]
        product4.createdAt = Date()
        product4.updatedAt = Date()
    }
    
    // MARK: - Properties
    
    public let container: NSPersistentContainer
    
    // MARK: - Initialization
    
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Ecommerce")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    
    /// Saves the main context if there are changes
    /// - Returns: Result indicating success or failure
    @discardableResult
    public func saveContext() -> Result<Bool, Error> {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                return .success(true)
            } catch {
                let nsError = error as NSError
                return .failure(nsError)
            }
        }
        return .success(false)
    }
    
    // MARK: - Background Context
    
    /// Creates a new background context for performing operations off the main thread
    /// - Returns: A new NSManagedObjectContext configured for background operations
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Delete All Data
    
    /// Deletes all data from the persistent store (useful for testing)
    /// - Parameter completion: Completion handler called after deletion
    public func deleteAllData(completion: (() -> Void)? = nil) {
        let context = newBackgroundContext()
        
        context.perform {
            let entityNames = ["Product", "Cart", "Order", "OrderItem", "User", "Address"]
            
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                } catch {
                    print("Failed to delete \(entityName): \(error)")
                }
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion?()
                }
            } catch {
                print("Failed to save after delete all: \(error)")
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
}
