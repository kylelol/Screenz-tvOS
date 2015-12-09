//
//  ScreenInfoView.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/1/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import StoreKit

protocol ScreenInfoViewDelegate: class {
     func didTapBuyButton(infoView: ScreenInfoView)
     func didTapPreviewButton(infoView: ScreenInfoView)
     func didTapPlayButton(infoView: ScreenInfoView)
     func priceForButton(productId: String) -> NSDecimalNumber?
     func isScreenPurchased(screen: Screen) -> Bool?
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
                
                //Check if free or not.
                if let purchased = self.delegate?.isScreenPurchased(screen) {
                    if purchased {
                        self.purchasedState()
                    } else {
                        //Can force unwrap becuase it has to be set to get here.
                        buyState(self.delegate?.priceForButton(screen.productId!))
                    }
                    
                } else {
                    freeState()
                }
                
                //Check if we have product Id.
              /*  if let productId = screen.productId {
                    print("We have product id \(productId)")
                    if let product = self.delegate?.priceForButton(productId) {
                        self.buyButton?.userInteractionEnabled = true
                        self.buyButton!.setTitle("$\(product.price)", forState: .Normal)
                        self.playButton!.userInteractionEnabled = false
                    }
                    
                } else {
                    self.buyButton?.userInteractionEnabled = false
                    self.buyButton?.setTitle("Free", forState: .Normal)
                    self.playButton!.userInteractionEnabled = true

                }*/
            }
        }
    }
    
    var product: SKProduct? {
        didSet {
            
        }
    }
    
    override weak var preferredFocusedView: UIView? {
        return self.playButton
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func didTapBuyButton(sender: AnyObject) {
        let text = self.buyButton!.titleLabel!.text!
        if text != "Free" && text != "Bought" {
            self.delegate?.didTapBuyButton(self)
        }
    }
    
    @IBAction func didTapPrviewButton(sender: AnyObject) {
        self.delegate?.didTapPreviewButton(self)
    }
    
    @IBAction func didTapPlayButton(sender: AnyObject) {
        let text = self.buyButton!.titleLabel!.text!

        if text == "Free" || text == "Bought" {
            self.delegate?.didTapPlayButton(self)
        } else {
            self.delegate?.didTapBuyButton(self)
        }
    }
    
    private func freeState() {
        //self.buyButton?.userInteractionEnabled = false
        self.buyButton?.setTitle("Free", forState: .Normal)
       // self.playButton!.userInteractionEnabled = true
    }
    
    private func buyState(price: NSDecimalNumber?) {
        //self.buyButton?.userInteractionEnabled = true
        
        if let price = price {
            self.buyButton!.setTitle("$\(price)", forState: .Normal)
        } else {
            
        }
       // self.playButton!.userInteractionEnabled = false
    }
    
    private func purchasedState() {
        //self.buyButton?.userInteractionEnabled = false
        self.buyButton?.setTitle("Bought", forState: .Normal)
       // self.playButton!.userInteractionEnabled = true
    }
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
