//
//  ViewController.swift
//  Waldo
//
//  Copyright © 2018 DFeichtinger. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, NSSearchFieldDelegate, NSWindowDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate {

    @IBOutlet weak var workspaceView: NSStackView!
    @IBOutlet weak var workspaceScrollView: NSScrollView!
    @IBOutlet weak var suggestionList: NSTableView!
    @IBOutlet weak var taskView: NSView!
    @IBOutlet weak var taskField: NSSearchField!
    @IBOutlet weak var suggestionsScrollView: NSScrollView!
    @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var archivedPanelsView: NSCollectionView!
    
    var maxPanelWidth: CGFloat {
        get { return workspaceScrollView.frame.width }
    }
    
    var paddingWidth: CGFloat! {
        get {
            if childViewControllers.count == 0 {
                return 0
            } else {
                // Magic number, how many pixels of a panel overlap when at maximum scroll
                return workspaceScrollView.frame.width - 100
            }
        }
    }
    
    private let taskDelegate = TaskFieldDelegate()
    private var activePanelVC: PanelViewController?
    private var suggestionSelected = false
    private var windowResizeDelta = CGFloat.init()
    private var archivedPanels: [Panel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        suggestionList.delegate = taskDelegate
        suggestionList.dataSource = taskDelegate
        suggestionList.reloadData()
        
        taskField.delegate = self
        
        archivedPanelsView.delegate = self
        archivedPanelsView.dataSource = self
        archivedPanels = Panel.currentlyClosed(context: managedContext!)
        
        // Set shadow on task popup
        taskView.wantsLayer = true
        taskView.shadow = NSShadow()
        taskView.layer?.shadowRadius = 5.0
        taskView.layer?.shadowOpacity = 1.0
        
        Panel.currentlyOpen(context: managedContext!).forEach { loadPanel($0) }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        scrollViewLeadingConstraint.constant = paddingWidth
        scrollViewTrailingConstraint.constant = paddingWidth
        
        if !UserDefaults.standard.bool(forKey: "HasRun") {
            UserDefaults.standard.set(true, forKey: "HasRun")
            showTaskBar(self)
        }
        
        centreActivePanel()
        archivedPanelsView.scroll(NSPoint.init(x: archivedPanelsView.frame.width, y: 0.0))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.window?.delegate = self
    }
    
    // MARK: Actions
    @IBAction func showTaskBar(_ sender: Any) {
        taskDelegate.updateSuggestions(taskField.stringValue)
        suggestionList.reloadData()
        taskView.isHidden = false
        view.window?.makeFirstResponder(taskField)
        if suggestionList.numberOfRows > 0 {
            suggestionList.selectRowIndexes(IndexSet.init(integer: 0), byExtendingSelection: false)
        }
    }
    
    @objc @IBAction func addPanelFromTask(_ sender: Any) {
        if suggestionSelected {
            addPanelFromSuggestion(self)
        } else if taskField.stringValue != "" {
            let task = Task.init(taskField.stringValue)
            for (index, result) in task.taskResults.enumerated() {
                let visit = Visit.init(request: result.urlRequest, intentType: result.intentType, intentText: result.intentText, context: managedContext!)
                save()
                if index == 0 {
                    addPanel(visit, makeActive: true)
                } else {
                    addPanel(visit)
                }
            }
            taskView.isHidden = true
        }
    }
    
    @IBAction func addPanelFromSuggestion(_ sender: Any) {
        let suggestion = taskDelegate.suggestions[suggestionList.selectedRow]
        if currentUrls.contains(suggestion.url!) {
            changeActivePanel(childViewControllers[currentUrls.index(of: suggestion.url!)!] as! PanelViewController)
        } else {
            let request = URLRequest.init(url: URL.init(string: suggestion.url!)!)
            let visit = Visit.init(request: request, intentType: .followedSuggestion, intentText: suggestion.title, context: managedContext!)
            save()
            addPanel(visit, makeActive: true)
        }
        taskView.isHidden = true
    }
    
    @IBAction func movePanelFocusLeft(_ sender: Any) {
        if activePanelVC != nil {
            let newPanelIndex = mod(activePanelIndex! - 1, workspaceView.views.count)
            changeActivePanel(panelViewController(at: newPanelIndex))
            centreActivePanel()
        }
    }
    
    @IBAction func movePanelFocusRight(_ sender: Any) {
        if activePanelVC != nil {
            let newPanelIndex = mod(activePanelIndex! + 1, workspaceView.views.count)
            changeActivePanel(panelViewController(at: newPanelIndex))
            centreActivePanel()
        }
    }
    
    @IBAction func centerActivePanel(_ sender: Any) {
        centreActivePanel()
    }
    
    @IBAction func closeActivePanel(_ sender: Any) {
        removePanel(activePanelVC!)
    }
    
    @IBAction func reloadActivePanel(_ sender: Any) {
        activePanelVC?.reload(self)
    }
    
    @IBAction func reopenLastPanel(_ sender: Any) {
        if let latest = Panel.lastClosed(context: managedContext!) {
            latest.isClosed = false
            latest.closedAt = nil
            loadPanel(latest, at: Int.init(latest.positionIndex))
        }
    }
    
    @IBAction func copyURLToClipboard (_ sender: Any) {
        if activePanelVC != nil {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            pasteboard.setString(activePanelVC!.webView!.url?.absoluteString ?? "", forType: NSPasteboard.PasteboardType.string)
        }
    }
    
    // MARK: Task entry functions
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(moveUp(_:)):
            suggestionSelected = true
            suggestionList.keyDown(with: NSApp.currentEvent!)
            return true
        case #selector(moveDown(_:)):
            suggestionSelected = true
            suggestionList.keyDown(with: NSApp.currentEvent!)
            return true
        case #selector(cancelOperation(_:)):
            suggestionSelected = false
            taskView.isHidden = true
            return true
        default:
            return false
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        suggestionSelected = false
        taskDelegate.updateSuggestions(taskField.stringValue)
        suggestionList.reloadData()
    }
    
    // MARK: Public panel management methods
    func changeActivePanel(_ panelViewController: PanelViewController) {
        if panelViewController != activePanelVC {
            activePanelVC?.isActive = false
            panelViewController.isActive = true
            activePanelVC = panelViewController
            view.window?.makeFirstResponder(activePanelVC?.backButton)
        }
    }
    
    func addPanel(_ visit: Visit, from: NSView? = nil, withWebView webView: WaldoWebView? = nil, makeActive: Bool = false) {
        let defaultWidth = UserDefaults.standard.float(forKey: "PanelWidth")
        let width = defaultWidth == 0.0 ? 550.0 : defaultWidth
        let panel = Panel.init(visit: visit, width: width, context: managedContext!)
        let panelViewController = initPanelVC(for: panel)

        if from != nil {
            let newPanelIndex = workspaceView.views.index(of: from!)! + 1
            workspaceView.insertView(panelViewController.view, at: newPanelIndex, in: .trailing)
        } else {
            workspaceView.addView(panelViewController.view, in: .trailing)
            if makeActive {
                changeActivePanel(panelViewController)
                centreActivePanel()
            }
        }
        workspaceDidChange()
        
        if webView == nil {
            panelViewController.navigate(visit)
        } else {
            panelViewController.replaceWebViewWith(webView!)
        }
    }
    
    func removePanel(_ panelViewController: PanelViewController) {
        if childViewControllers.count == 1 {
            activePanelVC = nil
        } else if panelViewController == activePanelVC {
            if activePanelIndex == 0 {
                movePanelFocusRight(self)
            } else {
                movePanelFocusLeft(self)
            }
        }
        
        let panel = panelViewController.panel!
        let config = WKSnapshotConfiguration.init()
        let width = panelViewController.webView.frame.width
        
        panel.closedAt = NSDate.init()
        panel.isClosed = true
        save()
        archivedPanels.append(panel)
        
        config.rect = NSRect.init(x: 0, y: 0, width: width, height: width)
        panelViewController.webView.takeSnapshot(with: config) { (image, error) in
            if let image = image {
                panel.image = image.png as NSData?
                self.archivedPanelsView.reloadData()
            } else {
                debugPrint(error!.localizedDescription)
            }
        }
        
        workspaceView.removeView(panelViewController.view)
        let index = childViewControllers.index(of: panelViewController)!
        removeChildViewController(at: index)
        workspaceDidChange()
        centreActivePanel()
        archivedPanelsView.reloadData()
        archivedPanelsView.layoutSubtreeIfNeeded()
        archivedPanelsView.scroll(NSPoint.init(x: archivedPanelsView.frame.width, y: 0.0))
    }
    
    func windowDidResize(_ notification: Notification) {
        let currentWidth = workspaceScrollView.contentView.documentVisibleRect.origin.x
        let newOrigin = NSPoint.init(x: currentWidth + windowResizeDelta, y: 0)
        workspaceScrollView.contentView.scroll(to: newOrigin)
        
        scrollViewLeadingConstraint.constant = paddingWidth
        scrollViewTrailingConstraint.constant = paddingWidth
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        windowResizeDelta = frameSize.width - workspaceScrollView.frame.width
        return frameSize
    }
    
    func centreActivePanel() {
        if activePanelVC != nil {
            let screenOffset = (workspaceScrollView.frame.width - activePanelVC!.view.frame.width) / 2
            var offset = workspaceView.subviews.prefix(activePanelIndex!).map { $0.frame.width }.reduce(0, +) + scrollViewLeadingConstraint.constant
            if screenOffset > 0 { offset = offset - screenOffset }
            workspaceScrollView.contentView.scroll(to: NSPoint.init(x: offset.rounded(), y: 0))
        }
    }
    
    // MARK: Collection View Data Source
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return archivedPanels.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let panel = archivedPanels[indexPath.item]
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ArchivedPanelViewItem"), for: indexPath) as! ArchivedPanelViewItem
        item.panel = panel
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let index = indexPaths.first!.item
        let panel = archivedPanels[index]
        panel.closedAt = nil
        panel.isClosed = false
        loadPanel(panel)
        archivedPanels.remove(at: index)
        changeActivePanel(panelViewController(at: Int.init(panel.positionIndex)))
        archivedPanelsView.reloadData()
    }
    
    // MARK: Private methods
    private func loadPanel(_ panel: Panel, at index: Int? = nil) {
        let panelViewController = initPanelVC(for: panel)
        if panel.isActive {
            activePanelVC = panelViewController
        }
        let panelView = panelViewController.view
        if index == nil {
            workspaceView.addView(panelView, in: .trailing)
        } else {
            workspaceView.insertView(panelView, at: index!, in: .trailing)
        }
        workspaceDidChange()
        panelViewController.loadResource()
    }
    
    private func initPanelVC(for panel: Panel) -> PanelViewController {
        let panelViewController =
            storyboard!.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("PanelViewController")
                ) as! PanelViewController
        panelViewController.delegate = self
        panelViewController.panel = panel
        addChildViewController(panelViewController)
        return panelViewController
    }
    
    private var currentUrls: [String] {
        get {
            return childViewControllers.compactMap { panelVC in
                (panelVC as! PanelViewController).panel.currentVisit?.url
            }
        }
    }
    
    private var activePanelIndex: Int? {
        get {
            return workspaceView.views.index(of: activePanelVC!.view)
        }
    }
    
    private func panelViewController(at index: Int) -> PanelViewController {
        return childViewControllers.filter { $0.view == workspaceView.views[index] }.first as! PanelViewController
    }
    
    private func workspaceDidChange() {
        childViewControllers.forEach { (panelVC) in
            (panelVC as! PanelViewController).panel.positionIndex =
                Int16.init(workspaceView.views.index(of: panelVC.view)!)
        }
        
        scrollViewLeadingConstraint.constant = paddingWidth
        scrollViewTrailingConstraint.constant = paddingWidth

        save()
    }
    
    // MARK: Data management
    private var managedContext: NSManagedObjectContext? {
        get {
            let appDelegate = NSApplication.shared.delegate as? AppDelegate
            return appDelegate?.persistentContainer.viewContext
        }
    }
    
    private func save() {
        do {
            try managedContext!.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
