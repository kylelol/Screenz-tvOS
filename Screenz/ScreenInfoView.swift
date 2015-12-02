//
//  ScreenInfoView.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit

class ScreenInfoView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    var screen: Screen? {
        didSet {
            if let screen = screen {
                titleLabel?.text = screen.title
                descriptionLabel?.text = screen.description
            }
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
