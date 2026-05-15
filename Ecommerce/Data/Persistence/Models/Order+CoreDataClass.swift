//
//  Order+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(Order)
public class Order: NSManagedObject {

}

extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var orderNumber: String?
    @NSManaged public var totalAmount: NSDecimalNumber
    @NSManaged public var subtotal: NSDecimalNumber?
    @NSManaged public var taxAmount: NSDecimalNumber?
    @NSManaged public var shippingAmount: NSDecimalNumber?
    @NSManaged public var discountAmount: NSDecimalNumber?
    @NSManaged public var status: String
    @NSManaged public var paymentMethod: String?
    @NSManaged public var paymentStatus: String?
    @NSManaged public var shippingMethod: String?
    @NSManaged public var trackingNumber: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}


