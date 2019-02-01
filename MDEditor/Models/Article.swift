//
//  Article.swift
//  MDEditor
//
//  Created by Ashoka on 2019/1/31.
//  Copyright © 2019 Ashoka. All rights reserved.
//

import UIKit

struct Article: Codable {
    var title: String?
    var data: String?
    var createAt: Date?
    var updateAt: Date?
    var uuid: String?
    var tags: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case title, data, createAt, updateAt, uuid, tags
    }
    
    static func fromData(_ data: Data) -> Article? {
        let decoder = JSONDecoder()
        let model = try? decoder.decode(Article.self, from: data)
        return model
    }
    
    init(title: String?, data: String?, createAt: Date?, updateAt: Date?, tags: [String]?) {
        self.title = title
        self.data = data
        self.createAt = createAt ?? Date()
        self.updateAt = updateAt ?? Date()
        self.tags = tags
        self.uuid = UUID().uuidString
    }
    
    func encodeToJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        if data != nil {
            let jsonString = String(data: data!, encoding: .utf8)
            print("encoded string:\(jsonString)")
            return jsonString
        }
        return nil
    }
}
