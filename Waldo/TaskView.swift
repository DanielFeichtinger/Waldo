//
//  TaskView.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class TaskView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = CGColor.init(gray: 0.2, alpha: 0.8)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        wantsLayer = true
        layer?.backgroundColor = CGColor.init(gray: 0.2, alpha: 0.8)
    }
}
