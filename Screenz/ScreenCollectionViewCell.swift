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
    
    @IBOutlet weak var restorePurchasesLabel: UILabel!
    
    var screen: Screen? {
        didSet {
            if let screen = screen {
                
            }
        }
    }
    
    func restorePurchasesState() {
       // self.restorePurchasesLabel.hidden = false
        self.backgroundColor = UIColor.blackColor()
        self.contentView.backgroundColor = UIColor.darkGrayColor()
        self.thumbnailImage!.image =  UIImage(named: "square-restore")
        //self.bringSubviewToFront(self.restorePurchasesLabel)
    }
    
}
