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
    var purchases = [String]()
    
    init(screens: [Screen], purchases: [String]) {
        self.screens = screens
        self.purchases = purchases
        
    }
}

// MARK:- Reading from disc
extension DataStore {
    convenience init(plistURL: NSURL) {
        guard let rawDict = DataStore.loadPlistFromURL(plistURL)//,
           // let screenArray = rawDict["screens"] as? [[String : AnyObject]],
            //let screens = Screen.fromDictArray(screenArray) else { 
            else {
                
                //TODO: Check for purchases in defaults and load them. 
                if let purchases = NSUserDefaults.standardUserDefaults().objectForKey("purchases") {
                    print("We have purchases \(purchases)")
                    self.init(screens: [Screen](), purchases: purchases as! [String])
                    return
                }
                self.init(screens: [Screen](), purchases: [String]())
                return
        }
        
        //print(rawDict)
        var screens = [Screen]()
        for screen in rawDict {
            print(screen)
            screens.append(Screen.init(dict: screen as! [String : AnyObject])!)
        }
        
        
        var pArray = [String]()
        if let purchases = NSUserDefaults.standardUserDefaults().objectForKey("purchases") {
            pArray = purchases as! [String]
        }
        
        self.init(screens: screens, purchases: pArray)
    }
    
    convenience init(plistName: String) {
        let fileURL = NSURL.urlForFileInDocumentsDirectory(plistName, fileExtension: "plist")
        self.init(plistURL: fileURL)
    }
    
    convenience init() {
        self.init(plistName: "screenz")
    }
    
    private static func loadPlistFromURL(plistURL: NSURL) -> [AnyObject]? {
        let rawDict = NSArray(contentsOfURL: plistURL)
        return rawDict as? [AnyObject]
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
            "screens" : screens.map { $0.dictRepresentation }, "purchases": purchases
            ] as NSDictionary
        dispatch_async(dispatch_get_main_queue()) {
            serialisedData.writeToURL(NSURL.urlForFileInDocumentsDirectory(plistName, fileExtension: "plist"), atomically: true)

        }
    }
    
    func save() {
        save(plistName: "screenz")
    }
    
    func savePurchases() {
        NSUserDefaults.standardUserDefaults().setObject(self.purchases, forKey: "purchases")
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
        return self.screens.count
    }
    
    func cv_objectForRowAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        
        if indexPath.row < self.screens.count {
            return self.screens[indexPath.row]
        }
        
        return nil
    }

    
}

//MARK: Purchase Management
extension DataStore {
    func addPurchase(purchase: String) {
        purchases.append(purchase)
        savePurchases()
    }
    
    //Nil for free
    // No for not purchased
    //Yes for puchased. 
    func isScreenPurchased(screen: Screen) -> Bool? {
        
        guard let id = screen.productId else {
            return nil
        }
        
        return purchases.contains(id)
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
    
    func priceForProductId(pID: String?) -> NSDecimalNumber? {
        if let product = self.productForProductId(pID) {
            return product.price
        } else {
            return nil
        }
    }
    
    func productForProductId(pId: String?) -> SKProduct? {
        
       let index =  self.products.indexOf { (product) -> Bool in
            return product.productIdentifier == pId
        }
        
        if index != nil {
            let product = self.products[index!]
            return product

        } else {
            return nil
        }
        
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