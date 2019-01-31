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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        setupJavascript()
    }

    func setupViews() {
        bodyTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        bodyTextView.inputAccessoryView = inputBar
    }

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

    func htmlString() -> String {
        struct Static {
            static var css :String!
            static var htmlTemplate :String!
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kShowPreviewSegueId {
            let vc = segue.destination as! PreviewViewController
            vc.title = titleTextField.text ?? "预览"
            vc.htmlString = htmlString()
        }
    }
}
