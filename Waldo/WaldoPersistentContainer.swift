//
//  WaldoPersistentContainer.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import CoreData

class WaldoPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        let dir = Bundle.main.infoDictionary!["DATA_DIR"] as! String
        var url = NSPersistentContainer.defaultDirectoryURL()
        url.appendPathComponent("../\(dir)")
        return url.standardizedFileURL
    }
}
