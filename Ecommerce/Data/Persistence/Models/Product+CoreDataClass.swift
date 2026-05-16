//
//  Product+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(Product)
public class Product: NSManagedObject, Identifiable {

}

extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var price: NSDecimalNumber
    @NSManaged public var category: String?
    @NSManaged public var images: [String]?
    @NSManaged public var stockQuantity: Int32
    @NSManaged public var rating: Double
    @NSManaged public var isFeatured: Bool
    @NSManaged public var isOnSale: Bool
    @NSManaged public var salePrice: NSDecimalNumber?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var brand: String?
    @NSManaged public var sku: String?

}


