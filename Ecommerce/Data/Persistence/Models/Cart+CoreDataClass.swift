//
//  Cart+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(Cart)
public class Cart: NSManagedObject, Identifiable {

}

extension Cart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart> {
        return NSFetchRequest<Cart>(entityName: "Cart")
    }

    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var productId: String
    @NSManaged public var quantity: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}


