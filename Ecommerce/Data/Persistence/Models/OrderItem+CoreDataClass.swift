//
//  OrderItem+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(OrderItem)
public class OrderItem: NSManagedObject {

}

extension OrderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }

    @NSManaged public var id: String
    @NSManaged public var orderId: String
    @NSManaged public var productId: String
    @NSManaged public var quantity: Int32
    @NSManaged public var price: NSDecimalNumber
    @NSManaged public var productName: String?
    @NSManaged public var productImage: String?

}


