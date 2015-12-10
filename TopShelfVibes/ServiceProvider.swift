//
//  ServiceProvider.swift
//  TopShelfVibes
//
//  Created by Kyle Kirkland on 12/9/15.
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
        
        let sectionIdentifier = TVContentIdentifier(identifier: "TopShelf.screenz", container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
        sectionItem!.title = "Quick Vibes"
        
        let fave1 = createContentItem("firewide", title: "Christmas Fireplace")
        let fave2 = createContentItem("snowman", title: "Snow Buddies")
        let fave3 = createContentItem("close", title: "A Little Closer")
        let fave4 = createContentItem("candles", title: "Candle Trifecta")
        let fave5 = createContentItem("santa", title: "Santa Says Hey")

        
        sectionItem!.topShelfItems = [fave1, fave2, fave3, fave4, fave5]
        return [sectionItem!]
    }
    
    func createContentItem(name: String, title: String) -> TVContentItem {
        let itemID = TVContentIdentifier(identifier: "TopShelf.screenz.\(name)", container: nil)
        let itemContent = TVContentItem(contentIdentifier: itemID!)
        
        guard let imageURL = NSBundle.mainBundle().URLForResource(name, withExtension: "png") else {
            fatalError("Error determining local image URL.") }
        
        itemContent!.imageURL = imageURL
        itemContent!.imageShape = .Square
        itemContent?.title = title
        
        let components = NSURLComponents()
        components.scheme = "TopShelf"
        components.path = "screenz"
        components.queryItems = [NSURLQueryItem(name: "id", value: name)]
        itemContent!.displayURL = components.URL
        
        return itemContent!
    }

}

