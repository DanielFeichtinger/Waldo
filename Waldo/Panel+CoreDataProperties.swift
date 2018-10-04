//
//  Panel+CoreDataProperties.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData


extension Panel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Panel> {
        return NSFetchRequest<Panel>(entityName: "Panel")
    }

    @NSManaged public var closedAt: NSDate?
    @NSManaged public var isActive: Bool
    @NSManaged public var isClosed: Bool
    @NSManaged public var positionIndex: Int16
    @NSManaged public var width: Float
    @NSManaged public var currentVisit: Visit?

}
