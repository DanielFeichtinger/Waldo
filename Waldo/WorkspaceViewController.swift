//
//  WorkspaceViewController.swift
//  HyperSomething
//
//  Created by Daniel Feichtinger on 06/02/2017.
//  Copyright © 2017 DFeichtinger. All rights reserved.
//

import Foundation
import AppKit

class WorkspaceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var workspaceTableView: NSTableView!
    
    override func viewDidLoad() {
        workspaceTableView.delegate = self
        workspaceTableView.dataSource = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = workspaceTableView.make(withIdentifier: "Cell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = "Workspace #\(row)"
        return cell
    }
}
