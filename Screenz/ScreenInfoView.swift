//
//  ScreenInfoView.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import StoreKit

@objc protocol ScreenInfoViewDelegate: class {
    optional func didTapBuyButton(infoView: ScreenInfoView)
    optional func didTapPreviewButton(infoView: ScreenInfoView)
    optional func didTapPlayButton(infoView: ScreenInfoView)
    optional func priceForButton(productId: String) -> SKProduct?
}

class ScreenInfoView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBOutlet weak var buyButton: UIButton?
    @IBOutlet weak var previewButton: UIButton?
    @IBOutlet weak var playButton: UIButton?
    
    weak var delegate: ScreenInfoViewDelegate?
    
    var screen: Screen? {
        didSet {
            if let screen = screen {
                titleLabel?.text = screen.title
                descriptionLabel?.text = screen.description
                
                if let productId = screen.productId {
                    print("We have product id \(productId)")
                    if let product = self.delegate?.priceForButton?(productId) {
                        self.buyButton?.userInteractionEnabled = true
                        self.buyButton!.setTitle("\(product.price)", forState: .Normal)

                    }
                    
                } else {
                    self.buyButton?.userInteractionEnabled = false
                    self.buyButton?.setTitle("Free", forState: .Normal)

                }
            }
        }
    }
    
    var product: SKProduct? {
        didSet {
            
        }
    }
    
    @IBAction func didTapBuyButton(sender: AnyObject) {
        self.delegate?.didTapBuyButton?(self)
    }
    
    @IBAction func didTapPrviewButton(sender: AnyObject) {
        self.delegate?.didTapPreviewButton?(self)
    }
    
    @IBAction func didTapPlayButton(sender: AnyObject) {
        self.delegate?.didTapPlayButton?(self)
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
