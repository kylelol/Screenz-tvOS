//
//  VibesPurchase.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/5/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation

enum VibesPurchase: String {
    case TestPurchase = "TestPurchase"
    case Bundle = "3Bundle"
    case Candles = "Candles"
    case FireplaceClose = "CloseFireplace"
    case Santa = "Santa"
    
    var productId: String {
        return (NSBundle.mainBundle().bundleIdentifier ?? "") + "." + rawValue
    }
    
    init?(productId: String) {
        guard let bundleID = NSBundle.mainBundle().bundleIdentifier
            where productId.hasPrefix(bundleID) else {
                return nil
        }
        self.init(rawValue: productId.stringByReplacingOccurrencesOfString(bundleID + ".", withString: ""))
    }
}