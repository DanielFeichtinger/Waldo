//
//  Panel+CoreDataClass.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Panel)
public class Panel: NSManagedObject {
    
    convenience init(visit: Visit, width: Float, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Panel", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.isActive = false
        self.isClosed = false
        self.currentVisit = visit
        self.width = width
    }
    
    class func currentlyOpen(context: NSManagedObjectContext) -> [Panel] {
        var panels: [Panel] = []
        do {
            let fetchRequest: NSFetchRequest<Panel> = Panel.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isClosed = false")
            panels = try context.fetch(fetchRequest).sorted { $0.positionIndex < $1.positionIndex }
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
        return panels
    }
    
    class func currentlyClosed(context: NSManagedObjectContext) -> [Panel] {
        var panels: [Panel] = []
        do {
            let fetchRequest: NSFetchRequest<Panel> = Panel.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isClosed = true")
            panels = try context.fetch(fetchRequest).sorted { ($0.closedAt! as Date) < ($1.closedAt! as Date) }
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
        return panels
    }
    
    class func lastClosed(context: NSManagedObjectContext) -> Panel? {
        var panel: Panel? = nil
        do {
            let fetchRequest: NSFetchRequest<Panel> = Panel.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isClosed = true")
            let panels = try context.fetch(fetchRequest)
            panel = panels.sorted { ($0.closedAt! as Date) > ($1.closedAt! as Date) }.first
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
        return panel
    }
    
}
