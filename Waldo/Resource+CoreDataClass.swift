//
//  Resource+CoreDataClass.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Resource)
public class Resource: NSManagedObject {
    
    class func updateOrCreateByResource(_ visit: Visit, in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Resource>(entityName: "Resource")
        let predicate = NSPredicate(format: "url = %@", visit.url!)
        fetchRequest.predicate = predicate
        var resource: Resource!
        
        do {
            let foundResults = try context.fetch(fetchRequest)
            if foundResults.count == 0 {
                let entity = NSEntityDescription.entity(forEntityName: "Resource", in: context)!
                resource = Resource.init(entity: entity, insertInto: context)
                resource.url = visit.url
                resource.visitCount = 1
            } else {
                resource = foundResults.first!
                resource.visitCount += 1
            }
            resource.title = visit.title
            resource.latestVisit = visit
            visit.resource = resource
            try context.save()
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    class func findByPattern(_ pattern: String, in context: NSManagedObjectContext) -> [Resource] {
        // This used to search all visits for patterns in historical title/URLs
        // but now just searches the latest resource state
        var resources: [Resource] = []
        let fetchRequest = NSFetchRequest<Resource>(entityName: "Resource")

        if !pattern.isEmpty {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR url CONTAINS[cd] %@", pattern, pattern)
            fetchRequest.predicate = predicate
        }
        
        do {
            let unsortedResources = try context.fetch(fetchRequest)
            resources = unsortedResources.sorted { $0.visitCount > $1.visitCount }
        } catch let error as NSError {
            debugPrint("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return resources
    }
    
}
