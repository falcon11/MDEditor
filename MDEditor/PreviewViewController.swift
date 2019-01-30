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
    var htmlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupWebView()
        loadHtml()
    }
    
    func setupWebView() {
        webView.navigationDelegate = self;
    }
    
    func loadHtml() {
        if htmlString != nil {
            webView.loadHTMLString(htmlString!, baseURL: nil)
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
}

extension PreviewViewController: WKNavigationDelegate {
    
}
