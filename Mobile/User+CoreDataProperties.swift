//
//  User+CoreDataProperties.swift
//  Dear Lampi
//
//  Created by Arohi Mehta on 4/2/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var username: String?
    @NSManaged public var deviceID: String?
    @NSManaged public var ipAddress: String?
    @NSManaged public var uniqueCode: String?

}

extension User : Identifiable {

}
