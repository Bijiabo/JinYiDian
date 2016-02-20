//
//  WebBrowserViewController.swift
//  Infomaina
//
//  Created by huchunbo on 16/1/3.
//  Copyright © 2016年 Bijiabo. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit

class WebBrowserViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var _navigationItem: UINavigationItem!
    
    private var webView: WKWebView!
    private var webViewProcessPool = WKProcessPool()
    private var messageHanderName: String = "reading"
    private var myContext = 0
    
    var uri: String = "http://www.smashingmagazine.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initViews()
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: uri)!))
    }
    
    private func _initViews() {
        _initWebView()
        _initProgressView()
    }
    
    private func _initWebView() {
        // setup webview's configuration
        let webViewConfiguration = WKWebViewConfiguration()
        
        if #available(iOS 9.0, *) {
            webViewConfiguration.applicationNameForUserAgent = "Infomaina-iOS"
            webViewConfiguration.allowsAirPlayForMediaPlayback = false
            webViewConfiguration.allowsAirPlayForMediaPlayback = true
            webViewConfiguration.requiresUserActionForMediaPlayback = true
            webViewConfiguration.allowsPictureInPictureMediaPlayback = true
        } else {
            webViewConfiguration.mediaPlaybackAllowsAirPlay = true
            webViewConfiguration.mediaPlaybackRequiresUserAction = true
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        preferences.javaScriptEnabled = true
        webViewConfiguration.preferences = preferences
        
        webViewConfiguration.processPool = webViewProcessPool
        
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.addScriptMessageHandler(self, name: messageHanderName)
        webViewConfiguration.userContentController = userContentController
        
        webViewConfiguration.suppressesIncrementalRendering = false
        webViewConfiguration.selectionGranularity = WKSelectionGranularity.Dynamic
        
        
        // setup webview
        webView = WKWebView(frame: CGRect(x: 0, y: 64.0, width: view.bounds.width, height: view.bounds.height-64.0), configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.UIDelegate = self
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.New, context: &myContext)
        
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
    }
    
    private func _initProgressView() {
        progressView.trackTintColor = UIColor.clearColor()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            guard let currentProgress: Double = change?[NSKeyValueChangeNewKey] as? Double else {return}
            _setProgressViewToValue(Float(currentProgress))
        }
    }
    
    // MARK: - user actions
    
    @IBAction func tapRefreshButton(sender: AnyObject) {
        _setProgressViewToValue(0, animated: false)
        webView.reload()
    }
    
    @IBAction func tapDoneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - helpful functions
    
    private func _setProgressViewToValue(value: Float, animated: Bool = true) {
        if value < 1 {
            progressView.alpha = 1.0
        } else {
            progressView.alpha = 0
        }
        progressView.setProgress(value, animated: animated)
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        progressView.setProgress(0, animated: false)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        _navigationItem.title = webView.title
        webView.evaluateJavaScript("$('#go_app,#header').hide();", completionHandler: nil)
    }
}

extension WebBrowserViewController: WKUIDelegate {
    
}

extension WebBrowserViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: String] else {return}
        guard let selectWord = messageBody["word"] else {return}
        print(selectWord)
    }
}