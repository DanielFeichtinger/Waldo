//
//  Resource+CoreDataProperties.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData


extension Resource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Resource> {
        return NSFetchRequest<Resource>(entityName: "Resource")
    }

    @NSManaged public var visitCount: Int64
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var latestVisit: Visit?

}
