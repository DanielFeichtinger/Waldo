//
//  WaldoWebView.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import WebKit

class WaldoWebView: WKWebView {
    
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.control) {
            self.superview?.scrollWheel(with: event)
        } else {
            super.scrollWheel(with: event)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        (uiDelegate as! PanelViewController).mouseDown(with: event)
        super.mouseDown(with: event)
    }
    
}
