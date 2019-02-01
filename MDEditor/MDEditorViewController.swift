//
//  ViewController.swift
//  MDEditor
//
//  Created by Ashoka on 2019/1/30.
//  Copyright © 2019 Ashoka. All rights reserved.
//

import JavaScriptCore
import UIKit

let kShowPreviewSegueId = "preview"

class MDEditorViewController: UIViewController {
    @IBOutlet var jsContext: JSContext!

    @IBOutlet var inputBar: UIToolbar!

    @IBOutlet var titleTextField: UITextField!

    @IBOutlet var bodyTextView: UITextView!

    var article: Article!

    var articleTitle: String? {
        return titleTextField.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initArticle()
        setupViews()
        setupJavascript()
        print("kTempFilePath:\(kTempFilePath)")
//        print("ktempfile relative path:\(shareFileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].relativePath)")
    }

    func initArticle() {
        let localArticleData = try? Data(contentsOf: URL(string: kTempFilePath)!)
        if localArticleData != nil {
            article = Article.fromData(localArticleData!)
        } else {
            article = Article(title: nil, data: nil, createAt: nil, updateAt: nil, tags: nil)
        }
    }

    func setupViews() {
        bodyTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        bodyTextView.inputAccessoryView = inputBar
        titleTextField.text = article.title
        bodyTextView.text = article.data
    }

    /// inject showdown.js and convert.js to jscontext
    func setupJavascript() {
        struct Static {
            static var showdownJs: String!
            static var convertJs: String!
        }
        if Static.showdownJs == nil {
            let showdownPath = Bundle.main.path(forResource: "showdown", ofType: "js")!
            Static.showdownJs = (try? String(contentsOfFile: showdownPath)) ?? ""
        }
        if Static.convertJs == nil {
            let convertPath = Bundle.main.path(forResource: "convert", ofType: "js")!
            Static.convertJs = (try? String(contentsOfFile: convertPath)) ?? ""
        }
        jsContext.exceptionHandler = { _, exception in
            print("\(exception?.toString() ?? "")")
        }
        let showdownJs = Static.showdownJs
        let convertJs = Static.convertJs
        if showdownJs != nil {
            jsContext.evaluateScript(showdownJs)
            if convertJs != nil {
                jsContext.evaluateScript(convertJs)
            }
        }
    }

    // MARK: - Actions

    @IBAction func previewAction(sender: UIBarButtonItem) {
        performSegue(withIdentifier: kShowPreviewSegueId, sender: self)
    }

    /// convert markdown content to html
    ///
    /// - Returns: html string
    func htmlString() -> String {
        struct Static {
            static var css: String!
            static var htmlTemplate: String!
        }
        if Static.css == nil {
            let cssPath = Bundle.main.path(forResource: "github-markdown", ofType: "css")!
            Static.css = (try? String(contentsOfFile: cssPath, encoding: .utf8)) ?? ""
        }
        if Static.htmlTemplate == nil {
            let htmlTemplatePath = Bundle.main.path(forResource: "index", ofType: "html")!
            Static.htmlTemplate = (try? String(contentsOfFile: htmlTemplatePath, encoding: .utf8)) ?? ""
        }
        let title = titleTextField.text ?? "预览"
        let mdBody = bodyTextView.text ?? ""
        let jsFunctionValue = jsContext.objectForKeyedSubscript("convert")
        let mdBodyHtml = jsFunctionValue?.call(withArguments: [mdBody])?.toString() ?? ""
        let css = Static.css!
        let htmlTemplate = Static.htmlTemplate!
        let html = String(format: htmlTemplate, "\(title)", "\(css)", "\(mdBodyHtml)")
        return html
    }

    @IBAction func handleInputBarItemPress(sender: UIBarButtonItem) {
        var selectedRange = bodyTextView.selectedRange
        var insertText = ""
        let title = sender.title ?? ""
        switch title {
        case "link":
            insertText = "[]()"
            selectedRange.location += 1
        case "img":
            insertText = "![]()"
            selectedRange.location += 4
        default:
            insertText = title
            selectedRange.location += 1
        }
        bodyTextView.insertText(insertText)
        bodyTextView.selectedRange = selectedRange
    }

    @IBAction func saveFileToTemp() {
        do {
            // should use url, using string path can't prefix with file://
            try shareFileManager.createDirectory(at: URL(string: kTempDirectory)!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("create temp directory failed: \(error)")
        }
        article.title = titleTextField.text
        article.data = bodyTextView.text
        article.updateAt = Date()
        let jsonString = article.encodeToJsonString()
        do {
            try jsonString?.write(to: URL(string: kTempFilePath)!, atomically: true, encoding: .utf8)
        } catch let error {
            print("writeFile failed\(error)")
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kShowPreviewSegueId {
            let vc = segue.destination as! PreviewViewController
            vc.title = titleTextField.text ?? "预览"
            vc.htmlString = htmlString()
        }
    }
}
