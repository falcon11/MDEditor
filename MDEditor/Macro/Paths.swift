//
//  Paths.swift
//  MDEditor
//
//  Created by Ashoka on 2019/1/31.
//  Copyright © 2019 Ashoka. All rights reserved.
//

import Foundation

let kArticleFileName = "content.json"
let kDocumentPath =  shareFileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
let kMarkdownFileDirectory = "\(kDocumentPath)Markdown"
let kTempDirectory = "\(kDocumentPath)Temp"
let kTempFilePath = "\(kTempDirectory)/\(kArticleFileName)"
