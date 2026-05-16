//
//  Address+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(Address)
public class Address: NSManagedObject, Identifiable {

}

extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var fullName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var street: String
    @NSManaged public var city: String
    @NSManaged public var state: String?
    @NSManaged public var zipCode: String?
    @NSManaged public var country: String
    @NSManaged public var isDefault: Bool
    @NSManaged public var addressType: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}


