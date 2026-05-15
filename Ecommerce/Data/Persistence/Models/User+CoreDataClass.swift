//
//  User+CoreDataClass.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

}

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var profileImage: String?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var gender: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var lastLoginAt: Date?

}


