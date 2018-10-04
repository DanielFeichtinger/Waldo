//
//  ResizeHandleView.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class ResizeHandleView: NSView {
    
    var delegate: PanelViewController!
    override var acceptsFirstResponder: Bool { return true }
    private var trackingArea: NSTrackingArea?
    @objc var backgroundColor: CGColor? {
        didSet {
            wantsLayer = true
            layer?.backgroundColor = backgroundColor
        }
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func mouseDragged(with event: NSEvent) {
        delegate.resizeWidth(event.deltaX)
    }
    
    override func mouseUp(with event: NSEvent) {
        delegate.persistWidth()
    }
    
    override func resetCursorRects() {
        let cursor: NSCursor = NSCursor.resizeLeftRight
        addCursorRect(bounds, cursor: cursor)
        cursor.setOnMouseEntered(true)
    }
    
    override func mouseEntered(with event: NSEvent) {
        backgroundColor = CGColor.init(red: 0, green: 122, blue: 255, alpha: 1)
        super.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        backgroundColor = CGColor.init(gray: 0, alpha: 0)
    }
    
    override func updateTrackingAreas() {
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
}
