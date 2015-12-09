//
//  ServiceProvider.swift
//  ScreenzTopShelf
//
//  Created by Kyle Kirkland on 12/8/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        // Create an array of TVContentItems.
        
        let sectionID = TVContentIdentifier(identifier: "Screenz.faves", container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionID!)
        sectionItem!.title = "Quick Vibes"
        
        let item1 = createContentItem("Test1")
        let item2 = createContentItem("Test2")
        let item3 = createContentItem("Test3")
        let item4 = createContentItem("Test4")
        let item5 = createContentItem("Test5")

        
        sectionItem!.topShelfItems = [item1, item2, item3, item4, item5]
        
        return [sectionItem!]
    }
    
    func createContentItem(name: String) -> TVContentItem {
        let itemId = TVContentIdentifier(identifier: "Screenz.faves.\(name)", container: nil)
        let itemContent = TVContentItem(contentIdentifier: itemId!)
        
        guard let imageURL = NSBundle.mainBundle().URLForResource("fire-wide", withExtension: "jpg") else {
            fatalError("Error determining local image URL.") }
        
        itemContent!.imageURL = imageURL
        itemContent!.imageShape = .Square
        
        let components = NSURLComponents()
        components.scheme = "Screenz"
        components.path = "faves"
        components.queryItems = [NSURLQueryItem(name: "id", value: name)]
        itemContent!.displayURL = components.URL
        
        return itemContent!
    }

}

