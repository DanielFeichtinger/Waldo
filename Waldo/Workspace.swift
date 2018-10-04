//
//  Workspace.swift
//  Waldo
//
//  Created by Daniel Feichtinger on 22/10/2017.
//  Copyright © 2017 DFeichtinger. All rights reserved.
//

import AppKit
import Foundation

class Workspace: Codable {
    
    var history: History = History()
    
//    override init() {
//        super.init()
//        // Add your subclass-specific initialization here.
//    }
//    
//    override class var autosavesInPlace: Bool {
//        return true
//    }
    
//    override func makeWindowControllers() {
//        // Returns the Storyboard that contains your Document window.
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
//        self.addWindowController(windowController)
//        windowController.contentViewController?.representedObject = self
//    }
//
//    override func data(ofType typeName: String) throws -> Data {
//        let encoder = JSONEncoder.init()
//        let jsonData = try encoder.encode(self)
//        return jsonData
//    }
//
//    override func read(from data: Data, ofType typeName: String) throws {
//        let decoder = JSONDecoder.init()
//        let data = try decoder.decode(Workspace.self, from: data)
//        self.history = data.history
//    }
    
}
