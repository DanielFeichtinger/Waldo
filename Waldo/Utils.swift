//
//  Utils.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import Foundation

// From https://stackoverflow.com/questions/41180292/negative-number-modulo-in-swift
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
