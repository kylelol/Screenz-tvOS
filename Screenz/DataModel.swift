//
//  DataModel.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation

protocol Serializable {
    
    init?(dict: [String : AnyObject])
    static func fromDictArray(array: [[String : AnyObject]]) -> [Self]?
    
    var dictRepresentation : [String : AnyObject] { get }
    
}

extension Serializable {
    static func fromDictArray(array: [[String : AnyObject]]) -> [Self]? {
        return array.flatMap { Self(dict: $0) }
    }
}

protocol TableViewFormatter {
    
    func numberOfRowsInSection(section: Int) -> Int
    func objectForRowAtIndexPath(indexPath: NSIndexPath) -> AnyObject?
    
}