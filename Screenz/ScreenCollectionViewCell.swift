//
//  ScreenCollectionViewCell.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/5/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit

class ScreenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView?
    
    var screen: Screen? {
        didSet {
            if let screen = screen {
                
            }
        }
    }
    
}
