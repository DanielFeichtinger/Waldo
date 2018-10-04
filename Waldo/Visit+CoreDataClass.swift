//
//  Visit+CoreDataClass.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//
//

import Foundation
import CoreData
import WebKit

@objc(Visit)
public class Visit: NSManagedObject {
    
    convenience init(request: URLRequest, intentType: IntentType, intentText: String?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Visit", in: context)!
        self.init(entity: entity, insertInto: context)

        self.urlRequest = request as NSURLRequest
        self.intentType = intentType
        self.intentText = intentText
    }
    
    convenience init(navigationAction: WKNavigationAction, intentText: String?, previous: Visit, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Visit", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.previous = previous
        self.intentText = intentText
        self.urlRequest = navigationAction.request as NSURLRequest
        switch navigationAction.navigationType {
        case .linkActivated:
            intentType = .followedLink
        case .formSubmitted:
            intentType = .submittedForm
        default:
            intentType = .other
        }
    }
    
    func updateResource(url: URL, title: String, context: NSManagedObjectContext) -> () {
        self.url = url.absoluteString
        self.title = title
        Resource.updateOrCreateByResource(self, in: context)
    }
    
    var displayText: String {
        get {
            var text: String
            
            if intentText == nil {
                text = urlRequest!.url!.absoluteString
            } else {
                text = intentText!
            }
            switch intentType {
            case .followedLink:
                return "Followed: \(text)"
            case .submittedForm:
                return "Submitted form…"
            case .followedSuggestion:
                return "Suggestion: \(text)"
            case .other:
                return "Unknown: \(text)"
            default:
                return text
            }
        }
    }

}

@objc public enum IntentType: Int16 {
    case followedLink = 1
    case submittedForm
    case enteredURL
    case searched
    case followedSuggestion
    case other
}
