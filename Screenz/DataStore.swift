//
//  DataStore.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation
import StoreKit

final class DataStore {
    // MARK:- Storage
    var screens = [Screen]()
    var products = [SKProduct]()
    
    init(screens: [Screen]) {
        self.screens = screens
    }
}

// MARK:- Reading from disc
extension DataStore {
    convenience init(plistURL: NSURL) {
        guard let rawDict = DataStore.loadPlistFromURL(plistURL),
            let screenArray = rawDict["screens"] as? [[String : AnyObject]],
            let screens = Screen.fromDictArray(screenArray) else {
                self.init(screens: [Screen]())
                return
        }
        
        self.init(screens: screens)
    }
    
    convenience init(plistName: String) {
        let fileURL = NSURL.urlForFileInDocumentsDirectory(plistName, fileExtension: "plist")
        self.init(plistURL: fileURL)
    }
    
    convenience init() {
        self.init(plistName: "screenz")
    }
    
    private static func loadPlistFromURL(plistURL: NSURL) -> [String : AnyObject]? {
        let rawDict = NSDictionary(contentsOfURL: plistURL)
        return rawDict as? [String : AnyObject]
    }
    
    static var defaultDataStorePresentOnDisk : Bool {
        guard let storePath = NSURL.urlForFileInDocumentsDirectory("screenz", fileExtension: "plist").path else {
            return false
        }
        return NSFileManager.defaultManager().fileExistsAtPath(storePath)
    }
}

// MARK:- Persisting
extension DataStore {
    func save(plistName plistName: String) {
        let serialisedData = [
            "screens" : screens.map { $0.dictRepresentation }
            ] as NSDictionary
        serialisedData.writeToURL(NSURL.urlForFileInDocumentsDirectory(plistName, fileExtension: "plist"), atomically: true)
    }
    
    func save() {
        save(plistName: "screenz")
    }
}

// MARK:- NSURL Util methods
extension NSURL {
    static var documentsDirectory : NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    }
    
    static func urlForFileInDocumentsDirectory(fileName: String, fileExtension: String) -> NSURL {
        return NSURL.documentsDirectory.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension(fileExtension)
    }
}

//MARK:- Screen TableView Helpers
extension DataStore: TableViewFormatter {
    
    func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case 0: return self.screens.count
        case 1: return self.products.count
        default: return 0
        }
    }
    
    func objectForRowAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        switch indexPath.section {
        case 0: return self.screens[indexPath.row]
        case 1: return self.products[indexPath.row]
        default: return nil
        }
    }
}

//MARK: Screen CollectionView Helpers 
extension DataStore: CollectionViewFormatter {
    
    func cv_numberOfRowsInSection(section: Int) -> Int {
        return self.screens.count + self.products.count
    }
    
    func cv_objectForRowAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        
        if indexPath.row < self.screens.count {
            return self.screens[indexPath.row]
        }
        
        return nil
    }

    
}

//MARK:- Products Management

extension DataStore {
    func batchAddProducts(products: [SKProduct]?) {
        guard let array = products else {
            return
        }
        self.products.removeAll()

        self.products.appendContentsOf(array)
    }
}

//Screen Management
extension DataStore {
    
    func batchAddScreens(screens: [Screen]?) {
        
        guard let array = screens else {
            return
        }
        
        self.screens.removeAll()
        self.screens.appendContentsOf(array)
        print(self.screens)
        save()
    }
    func addScreen(screen: Screen) {
        screens.append(screen)
        save()
    }
    
    func removeScreen(screen: Screen) {
        if let index = screens.indexOf(screen) {
            screens.removeAtIndex(index)
        }
    }
}