//
//  Utils.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

// From https://stackoverflow.com/questions/41180292/negative-number-modulo-in-swift
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

// From https://stackoverflow.com/questions/29262624/nsimage-to-nsdata-as-png-swift
extension NSBitmapImageRep {
    var png: Data? {
        return representation(using: .png, properties: [:])
    }
}

extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}

extension NSImage {
    var png: Data? {
        return tiffRepresentation?.bitmap?.png
    }
}
