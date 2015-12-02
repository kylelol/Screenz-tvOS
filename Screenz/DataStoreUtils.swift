//
//  DataStoreUtils.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit

protocol DataStoreOwner {
    var dataStore : DataStore? { get set }
    
    func passDataStoreToChildren()
}


extension DataStoreOwner where Self : UIViewController {
    func passDataStoreToChildren() {
        for vc in childViewControllers {
            var dso = vc as? DataStoreOwner
            dso?.dataStore = dataStore
        }
    }
}
