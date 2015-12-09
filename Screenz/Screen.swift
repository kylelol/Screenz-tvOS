//
//  Screen.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation

final class Screen {
    let id: Int
    let url: String
    let title: String
    let description: String
    let productId: String?
    
    init(id: Int, url: String, title: String, description: String, productId: String?) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        
        if let prodId = productId {
            if productId == "" {
                self.productId = nil
            } else {
                self.productId = prodId
            }

        } else {
            self.productId = nil
        }
    }
}

extension Screen {
    static func screensWithJsonData(data: [JSON]) -> [Screen]? {
        
        var screens: [Screen] = []
        for json in data {
            print(json)
            guard let id = json["id"].int,
                   let url = json["url"].string,
                    let title = json["title"].string,
                    let desc = json["description"].string else {
                return nil
            }
            
            var productId: String?
            if let product = json["sk_product"].dictionaryObject {
                print("\(product["product_id"])")
                productId = product["product_id"]! as! String
            }
            
            screens.append(Screen(id: id, url: url, title: title, description: desc, productId: productId))
            
        }
        return screens 
    }
}

extension Screen : Serializable {
    convenience init?(dict: [String : AnyObject]) {
        guard
            let url = dict["url"] as? String,
            let title = dict["title"] as? String,
            let desc = dict["description"] as? String else {
                return nil
        }
        
        self.init(id: 0, url: url, title: title, description: desc, productId: dict["purchaseId"] as? String)
    }
    
    var dictRepresentation : [String : AnyObject] {
        return [
            "url"          : url,
            "title"         : title,
            "description"   : description,
            "purchaseId"     : productId != nil ? productId! : ""
        ]
    }
}

extension Screen : Equatable {
    // Free function below
}

func ==(lhs: Screen, rhs: Screen) -> Bool {
    return lhs.id == rhs.id
}

extension Screen : Hashable {
    var hashValue : Int {
        return id.hashValue
    }
}
