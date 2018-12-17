//
//  ArchivedPanelViewItem.swift
//  Waldo
//
//  Created by Daniel Feichtinger on 15/11/2018.
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import Cocoa

class ArchivedPanelViewItem: NSCollectionViewItem {
    
    var panel: Panel? {
        didSet {
            guard isViewLoaded else { return }
            if panel?.image != nil {
                imageView?.image = NSImage.init(data: panel?.image as! Data)
            } else {
                imageView?.image = nil
                textField?.stringValue = panel?.currentVisit?.title ?? "No title"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepareForReuse() {
        imageView?.image = nil
        textField?.stringValue = ""
        super.prepareForReuse()
    }
    
}
