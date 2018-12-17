//
//  Task.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class Task {
    let input: String
    var intentType: IntentType
//    var urlRequest: URLRequest
    var taskResults: [TaskResult] = []
    
    let commands = [
        "!g": [
            "description": "Google",
            "urls": ["https://encrypted.google.com/search?q={{{s}}}"]
        ],
        "!maps": [
            "description": "Google Maps",
            "urls": ["https://www.google.com/maps?hl=en&q={{{s}}}"]
        ],
        "!a": [
            "description": "Amazon",
            "urls": [ "https://smile.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords={{{s}}}" ]
        ],
        "!news": [
            "description": "News",
            "urls": ["https://bbc.co.uk", "https://theguardian.co.uk"]
        ]
    ]
    
    init(_ input: String) {
        self.input = input
        
        var urls: [URL] = []
        let linkType = NSTextCheckingResult.CheckingType.link.rawValue
        let detector = try! NSDataDetector.init(types: linkType)
        let results = detector.matches(in: input, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, input.count))
        
        if results.count > 0 {
            intentType = .enteredURL
            urls.append(results.first!.url!)
        } else {
            intentType = .searched
            let inputArray = input.components(separatedBy: " ")
            if commands.keys.contains(inputArray.first!) {
                var urlStrings: [String] = commands[inputArray.first!]!["urls"]! as! [String]
                if inputArray.count > 1 {
                    let searchString = inputArray[1...(inputArray.count - 1)].joined(separator: "%20")
                    urlStrings = urlStrings.map { $0.replacingOccurrences(of: "{{{s}}}", with: searchString) }
                }
                urls = urlStrings.map { URL.init(string: $0)! }
            } else {
                urls.append(URL(string: "https://duckduckgo.com/?q=\(inputArray.joined(separator: "%20"))")!)
            }
        }

        urls.forEach { (url) in
            taskResults.append(TaskResult.init(intentType: intentType, intentText: input, urlRequest: URLRequest(url: url)))
        }
    }
    
}

struct TaskResult {
    let intentType: IntentType!
    let intentText: String!
    let urlRequest: URLRequest!
}
