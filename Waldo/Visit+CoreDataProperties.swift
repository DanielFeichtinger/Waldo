//
//  Visit+CoreDataProperties.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData


extension Visit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visit> {
        return NSFetchRequest<Visit>(entityName: "Visit")
    }

    @NSManaged public var intentText: String?
    @NSManaged public var intentType: IntentType
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlRequest: NSURLRequest?
    @NSManaged public var resource: Resource?
    @NSManaged public var previous: Visit?

}
