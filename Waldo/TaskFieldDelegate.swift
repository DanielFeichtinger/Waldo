//
//  TaskFieldDelegate.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import AppKit

class TaskFieldDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var suggestions: [Resource] = []
    var suggestionList: NSTableView?
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = suggestions[row]
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as! NSTableCellView
        
        if tableColumn!.identifier.rawValue == "url" {
            cell.textField?.stringValue = item.url!
        } else if tableColumn!.identifier.rawValue == "title" {
            if item.title != nil { cell.textField?.stringValue = item.title! }
        } else {
            cell.textField?.stringValue = String(item.visitCount)
        }
        
        return cell
    }
    
    func updateSuggestions(_ pattern: String) {
        let appDelegate = NSApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        suggestions = Array(Resource.findByPattern(pattern, in: managedContext!))
    }
    
}
