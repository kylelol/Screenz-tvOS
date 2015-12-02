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
    
    init(id: Int, url: String, title: String, description: String) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
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
            
            screens.append(Screen(id: id, url: url, title: title, description: desc))
            
        }
        return screens 
    }
}

extension Screen : Serializable {
    convenience init?(dict: [String : AnyObject]) {
        guard let id = dict["idKey"] as? Int,
            let url = dict["urlKey"] as? String,
            let title = dict["titleKey"] as? String,
            let desc = dict["descriptionKey"] as? String else {
                return nil
        }
        self.init(id: id, url: url, title: title, description: desc)
    }
    
    var dictRepresentation : [String : AnyObject] {
        return [
            "idKey"            : id,
            "urlKey"          : url,
            "titleKey"         : title,
            "descriptionKey"   : description
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