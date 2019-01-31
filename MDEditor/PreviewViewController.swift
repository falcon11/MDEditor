//
//  PreviewViewController.swift
//  MDEditor
//
//  Created by Ashoka on 2019/1/30.
//  Copyright © 2019 Ashoka. All rights reserved.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    var htmlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupWebView()
        loadHtml()
    }
    
    func setupWebView() {
        webView.navigationDelegate = self;
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    func loadHtml() {
        if htmlString != nil {
            webView.loadHTMLString(htmlString!, baseURL: nil)
        }
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.progress = progress
            progressView.isHidden = progress == 1.0
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

// MARK: - WKNavigationDelegate
extension PreviewViewController: WKNavigationDelegate {
    
}
