//
//  TileViewController.swift
//  Waldo
//
//  Created by Daniel Feichtinger on 30/12/2016.
//  Copyright © 2016 DFeichtinger. All rights reserved.
//

import Cocoa
import WebKit

class PanelViewController: NSViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    @IBOutlet weak var webView: WaldoWebView!
    @IBOutlet weak var intentLabel: NSTextField!
    @IBOutlet weak var visitCountLabel: NSTextField!
    @IBOutlet weak var contentView: NSStackView!
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var resizeHandleView: ResizeHandleView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSeparatorView: NSView!
    @IBOutlet weak var connectionImage: NSImageView!
    
    weak var delegate: ViewController!
    var intentText: String?
    var intentType: IntentType!
    var isShuttingDown = false
    var isLoading = true
    var observation: NSKeyValueObservation?
    
    var tile: Panel! {
        didSet {
            if widthConstraint != nil {
                widthConstraint.constant = CGFloat.init(tile.width)
            }
        }
    }
    var isActive: Bool {
        get {
            return tile.isActive
        }
        set(active) {
            tile.isActive = active
            backButton.isEnabled = active
            save()
            redrawSecurityBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        webView.uiDelegate = self
        resizeHandleView.delegate = self
        widthConstraint.constant = CGFloat.init(tile.width)
        redrawSecurityBar()
        
        // Set content view curved borders
        contentView.layer?.cornerRadius = 3.0
        contentView.layer?.masksToBounds = true
        
        // Set visit count pill shape
        visitCountLabel.wantsLayer = true
        visitCountLabel.layer?.cornerRadius = visitCountLabel.frame.height / 2.0
        visitCountLabel.layer?.masksToBounds = true

        if let path = Bundle.main.path(forResource: "NavigationEvent", ofType: "js") {
            if let source = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String {
                let userScript = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
                webView.configuration.userContentController.addUserScript(userScript)
                webView.configuration.userContentController.add(self, name: "followLinkHandler")
            }
        }
    }
    
    override func viewWillDisappear() {
        webView.loadHTMLString("", baseURL: nil)
        isShuttingDown = true
    }
    
    override func viewDidAppear() {
        if isActive { delegate!.scrollToActiveTile() }
    }
    
    @IBAction func destroyTile(_ sender: Any) {
        delegate.removeTile(self)
    }
    
    @IBAction func navBack(_ sender: Any) {
        if tile.currentVisit!.previous != nil {
            let previous = tile.currentVisit!.previous!
            tile.currentVisit = previous
            navigate(previous)
            save()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        webView.reload()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive linkText: WKScriptMessage) {
        intentText = (linkText.body as! String)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !isShuttingDown && webView.title != "" {
            isLoading = false
            tile.currentVisit?.updateResource(url: webView.url!, title: webView.title!, context: managedContext!)
            save()
            intentText = nil
            redrawSecurityBar()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame!.isMainFrame {
            let visit: Visit!
            if shouldCreateNewVisit(navigationType: navigationAction.navigationType) {
                visit = Visit.init(navigationAction: navigationAction, intentText: intentText, previous: tile.currentVisit!, context: managedContext!)
            } else {
                visit = tile.currentVisit
            }
            if navigationAction.modifierFlags.contains(.command) {
                decisionHandler(.cancel)
                intentText = nil
                delegate!.addTile(visit, from: view)
            } else {
                decisionHandler(.allow)
                tile.currentVisit = visit
                navigate(visit, load: false)
            }
        } else {
            decisionHandler(.allow)
        }
        save()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let newWebView = newWebViewForConfig(configuration)
        let visit = Visit.init(navigationAction: navigationAction, intentText: intentText, previous: tile.currentVisit!, context: managedContext!)
        if navigationAction.modifierFlags.contains(.command) {
            delegate.addTile(visit, from: view, withWebView: newWebView)
        } else {
            tile.currentVisit = visit
            replaceWebViewWith(newWebView)
            drawLoadingState()
        }
        save()
        return newWebView
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // TODO: show error somewhere
    }
    
    func navigate(_ visit: Visit, load: Bool = true) {
        // Why did I write any of this???
        intentText = visit.intentText
        intentType = visit.intentType
        isLoading = true
        if load {
            webView.load(visit.urlRequest! as URLRequest)
        }
        drawLoadingState()
    }
    
    func loadResource() {
        if tile.currentVisit != nil {
            intentType = tile.currentVisit?.intentType
            webView.load(tile.currentVisit!.urlRequest! as URLRequest)
            drawLoadingState()
        }
    }
    
    func replaceWebViewWith(_ newWebView: WaldoWebView) {
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        contentView.replaceSubview(webView, with: newWebView)
        webView = newWebView
    }
    
    private func newWebViewForConfig(_ config: WKWebViewConfiguration) -> WaldoWebView {
        let frame = NSRect.init()
        return WaldoWebView.init(frame: frame, configuration: config)
    }
    
    private func redrawSecurityBar() {
        if isActive {
            setBackgroundColor(contentView, CGColor.init(gray: 0.8, alpha: 1.0))
            setBackgroundColor(headerSeparatorView, CGColor.init(red: 0.98, green: 0.39, blue: 0.24, alpha: 1.0))
        } else {
            setBackgroundColor(contentView, CGColor.init(gray: 0.95, alpha: 1.0))
            setBackgroundColor(headerSeparatorView, CGColor.init(red: 0.98, green: 0.39, blue: 0.24, alpha: 0.5))
        }
        
        if webView.hasOnlySecureContent {
            connectionImage.image = NSImage.init(named: .lockLockedTemplate)
        } else {
            connectionImage.image = NSImage.init(named: .lockUnlockedTemplate)
        }
        if tile.currentVisit!.resource != nil {
            visitCountLabel.stringValue = "\(tile.currentVisit!.resource!.visitCount)"
        }
    }
    
    private func drawLoadingState() {
        intentLabel.stringValue = tile.currentVisit!.displayText
    }
    
    // This should be an extension, IB editable?
    func setBackgroundColor(_ view: NSView, _ color: CGColor) {
        view.wantsLayer = true
        view.layer?.backgroundColor = color
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate!.changeActiveTile(self)
    }
    
    func resizeWidth(_ delta: CGFloat) {
        let newWidth = widthConstraint.constant + delta
        if (delta < 0 && newWidth >= 250.0) ||
           (delta > 0 && newWidth <= delegate!.maxTileWidth)  {
            widthConstraint.constant = newWidth
            tile.width = Float.init(newWidth)
        }
    }
    
    func persistWidth() {
        save()
        UserDefaults.standard.set(tile.width, forKey: "TileWidth")
    }
    
    private func shouldCreateNewVisit(navigationType: WKNavigationType) -> Bool {
        // Todo — think this through fully. The navigation type from the action
        // May not be what we want. Maybe visits shouldn't be aware of WKNavigationActions
        // We just fully unwrap here
        if  navigationType == .backForward ||
            navigationType == .reload ||
            navigationType == .other ||
            isLoading {
                return false
        } else {
                return true
        }
    }
    
    var managedContext: NSManagedObjectContext? {
        get {
            let appDelegate = NSApplication.shared.delegate as? AppDelegate
            return appDelegate?.persistentContainer.viewContext
        }
    }
    
    func save() {
        do {
            try managedContext!.save()
        } catch let error as NSError {
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
