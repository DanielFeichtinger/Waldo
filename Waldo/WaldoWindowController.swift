//
//  WaldoWindowController.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class WaldoWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Work around stupid bug
        // Solution: https://stackoverflow.com/questions/47165996/xcode-9-storyboard-window-position-autosave
        self.windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: "position")
    }
}
