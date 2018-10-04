//
//  Task.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class Task {
    let input: String
    let intentType: IntentType!
    let intentText: String!
    let urlRequest: URLRequest!
    
    init(_ input: String) {
        self.input = input

        var url = URL(string: input)

        let inputArray = input.components(separatedBy: " ")

        let linkType = NSTextCheckingResult.CheckingType.link.rawValue
        let detector = try! NSDataDetector.init(types: linkType)
        let results = detector.matches(in: input, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, input.count))
        
        if results.count > 0 {
            url = results.first?.url
            intentText = input
            intentType = .enteredURL
        } else {
            intentType = .searched
            if inputArray.first == "!g" {
                let searchString = inputArray[1...(inputArray.count - 1)]
                intentText = searchString.joined(separator: " ")
                url = URL(string: "https://encrypted.google.com/search?q=\(searchString.joined(separator: "%20"))")
            } else {
                let searchString = inputArray.joined(separator: "%20")
                intentText = input
                url = URL(string: "https://duckduckgo.com/?q=\(searchString)")
            }
        }

        urlRequest = URLRequest(url: url!)
    }
    
}
