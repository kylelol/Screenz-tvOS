//
//  ScreenzViewController.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/5/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import StoreKit

class ScreenzViewController: UIViewController, IAPContainer, DataStoreOwner {
    
    var iapHelper : IAPHelper?
    
    var dataStore : DataStore? {
        didSet {
            if collectionView != nil {
                collectionView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var emptySpaceView: UIView!
    var focusedIndexPath: NSIndexPath?
    var playObject: Screen?
    var playerViewController: AVPlayerViewController?
    var queue: AVQueuePlayer!
    var focusGuide: UIFocusGuide!
    var bgVideoURL: NSURL?
    var backgroundPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenInfoView: ScreenInfoView?
    @IBOutlet weak var bgImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureCollectionView()
        self.screenInfoView?.screen = self.dataStore?.cv_objectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? Screen
        
        iapHelper?.requestProducts({ (products) -> () in
            print(products)
            print(products!.count)
            for product in products! {
                print(product.productIdentifier)
            }
            self.dataStore?.batchAddProducts(products)
            self.collectionView.reloadData()
        })
        
        self.focusGuide = UIFocusGuide()
        view.addLayoutGuide(self.focusGuide)
        self.focusGuide.topAnchor.constraintEqualToAnchor(self.emptySpaceView.topAnchor).active = true
        self.focusGuide.leftAnchor.constraintEqualToAnchor(self.emptySpaceView.leftAnchor).active = true
        self.focusGuide.widthAnchor.constraintEqualToAnchor(self.emptySpaceView.widthAnchor).active = true
        self.focusGuide.heightAnchor.constraintEqualToAnchor(self.emptySpaceView.heightAnchor).active = true
        
        self.screenInfoView?.delegate = self
       // self.startBgVideo()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handlePurchaseNotification:", name: IAPHelper.IAPHelperPurchaseNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showTopShelfVideo:"), name: "ShowFaveNotification", object: nil)

        self.newVideo("snowmen-loop-ATV")
    }
    
    func showTopShelfVideo(notification: NSNotification) {
        let favePizza = notification.userInfo!["Fave"] as! String
        
        var indexPath: NSIndexPath!
        print("favePizza:\(favePizza)")
        if favePizza.containsString("firewide") == true {
            indexPath = NSIndexPath(forRow: 1, inSection: 0)
        } else if favePizza.containsString("snowman") == true {
            indexPath = NSIndexPath(forRow: 2, inSection: 0)

        }else if favePizza.containsString("close") == true {
            indexPath = NSIndexPath(forRow: 3, inSection: 0)
            
        }else if favePizza.containsString("candles") == true {
            indexPath = NSIndexPath(forRow: 4, inSection: 0)
            
        }else if favePizza.containsString("santa") == true {
            indexPath = NSIndexPath(forRow: 5, inSection: 0)
            
        }
        
        self.playObject = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) as? Screen
        
        if let purchased = self.dataStore?.isScreenPurchased(self.playObject!) {
            if purchased {
                self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
            } else {
                let alert = UIAlertController()
                alert.title = "Purchase"
                alert.message = "Would you like to buy this video?"
                alert.addAction(UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    print("Time to buy")
                    if let ds = self.dataStore {
                        if let product = ds.productForProductId((ds.cv_objectForRowAtIndexPath(indexPath) as! Screen).productId!) {
                            print(product)
                            self.iapHelper?.buyProduct(product)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                    print("Cancel")
                }))
                self.showDetailViewController(alert, sender: nil)
            }
        } else {
            self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
            
        }


    }
    
    func newVideo(url: String) {
        let url = NSBundle.mainBundle().URLForResource(url, withExtension: "mov")
        let playerItem = AVPlayerItem(URL: url!)
        
        let tAsset = AVURLAsset(URL: url!)
        let tEditRange = CMTimeRangeMake(CMTimeMake(0,1), CMTimeMake(tAsset.duration.value, tAsset.duration.timescale))
        let tComposition = AVMutableComposition()
        for i in 0...10 {
            try! tComposition.insertTimeRange(tEditRange, ofAsset: tAsset, atTime: tComposition.duration)
        }
        
        let tAVPlayerItem = AVPlayerItem(asset: tComposition)
        if let bgPlayer = self.backgroundPlayer {
            self.backgroundPlayer!.pause()
            self.backgroundPlayer = AVPlayer(playerItem: tAVPlayerItem)
        } else {
            self.backgroundPlayer = AVPlayer(playerItem: tAVPlayerItem)

        }
        
        if let player = self.playerLayer {
            self.playerLayer!.removeFromSuperlayer()
            self.playerLayer! = AVPlayerLayer(player: self.backgroundPlayer)
        } else {
            self.playerLayer = AVPlayerLayer(player: self.backgroundPlayer)

        }
        
        self.playerLayer!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.view.layer.insertSublayer(self.playerLayer!, atIndex: 0)
        self.backgroundPlayer!.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoLoop", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.backgroundPlayer!.currentItem)
        
    }
    
    func videoLoop() {
        
        self.backgroundPlayer?.pause()
        self.backgroundPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.backgroundPlayer?.play()
    }
    
    func swapBgVideoWithScreen(screen: Screen?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.backgroundPlayer!.currentItem)
        self.newVideo(screen!.url)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.backgroundPlayer?.pause()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.collectionView.reloadData()
        
        self.backgroundPlayer?.play()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
        guard let nextFocusedView = context.nextFocusedView else {return }
        
        if nextFocusedView == self.emptySpaceView {
            print("updating focus")
            print(context.nextFocusedView)
            focusGuide.preferredFocusedView = self.screenInfoView?.previewButton
        } else {
            //focusGuide.preferredFocusedView = nil
            print(nextFocusedView.description)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
       // NSNotificationCenter.defaultCenter().removeObserver(self)
        self.backgroundPlayer?.pause()
        if segue.identifier == "ScreenPlayerSegue" {
            print("\(playObject!.url)")
           // let player = AVPlayer(URL: NSURL(string: playObject!.url)!)
            //(segue.destinationViewController as! ScreenzPlayerViewController).player = player
            //(segue.destinationViewController as! ScreenzPlayerViewController).videoURL =  NSURL(string: playObject!.url)!

            (segue.destinationViewController as! ScreenzPlayerViewController).screen = playObject

        }
    }
    
    func handlePurchaseNotification(notification: NSNotification) {
        if let transaction = notification.object as? SKPaymentTransaction {
                print(transaction.payment.productIdentifier)

                print("Time to give them there purchase")
                
                //TODO: Receipt validation and serving the content.
                self.iapHelper?.validateReceipt(transaction.payment.productIdentifier) { error in
                    
                    self.dataStore?.addPurchase(transaction.payment.productIdentifier)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.screenInfoView?.buyButton?.setTitle("Bought", forState: .Normal)
                    }
                }
                
        }
    }
    

}

extension ScreenzViewController: ScreenInfoViewDelegate {
    
    func isScreenPurchased(screen: Screen) -> Bool? {
        return self.dataStore?.isScreenPurchased(screen)
    }
    
    func didTapBuyButton(infoView: ScreenInfoView) {
        
        if let ds = self.dataStore {
            
            print(self.focusedIndexPath?.row)
            if let product = ds.productForProductId((ds.cv_objectForRowAtIndexPath(self.focusedIndexPath!) as! Screen).productId!) {
                print(product)
                self.iapHelper?.buyProduct(product)
            }
        }
        
    }
    
    func didTapPlayButton(infoView: ScreenInfoView) {
        self.playObject = infoView.screen
        
        if infoView.buyButton!.titleLabel!.text == "Free" || infoView.buyButton!.titleLabel!.text == "Bought" {
            self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)

        } else {
            
            if let purchased = self.dataStore?.isScreenPurchased(self.playObject!) {
                if purchased {
                    self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
                } else {
                    let alert = UIAlertController()
                    alert.title = "Would you like to buy this video for \(self.dataStore!.priceForProductId(infoView.screen!.productId)!)?"
                    alert.message = ""
                    alert.addAction(UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        print("Time to buy")
                        if let ds = self.dataStore {
                            if let product = ds.productForProductId(infoView.screen!.productId!) {
                                print(product)
                                self.iapHelper?.buyProduct(product)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                        print("Cancel")
                    }))
                    self.showDetailViewController(alert, sender: nil)
                }
            } else {
                self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
                
            }
            
        }
        
    }
    
    func didTapPreviewButton(infoView: ScreenInfoView) {
        
        self.swapBgVideoWithScreen(infoView.screen)
    }
    
    func priceForButton(productId: String) -> NSString? {
        return self.dataStore?.priceForProductId(productId)
    }
    
}

extension ScreenzViewController {
    
    func generateThumbnail(url: NSURL) -> UIImage? {
        
        var asset: AVAsset = AVAsset(URL: url)
        var assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        var image: UIImage?
        do {
            var img = try assetImgGenerate.copyCGImageAtTime(CMTimeMakeWithSeconds(durationSeconds/3.0, 600), actualTime: nil)
            image = UIImage(CGImage: img)
            self.bgImageView!.image = UIImage(CGImage: img)
            
            
        } catch {
            print("Something went wrong generating a thumbnail")
        }
        
        return image
    }
}

extension ScreenzViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BundleCollectionViewCell", forIndexPath: indexPath) as! UICollectionViewCell
            
            return cell
        }
        
        
  
        
        if indexPath.row >= self.dataStore?.screens.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ScreenzCell", forIndexPath: indexPath) as! ScreenCollectionViewCell
                cell.restorePurchasesState()
            return cell
        } else if let screen = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ScreenzCell", forIndexPath: indexPath) as! ScreenCollectionViewCell
            print((screen as! Screen).url)
            cell.restorePurchasesLabel.hidden = true
            let url = NSBundle.mainBundle().URLForResource((screen as! Screen).url, withExtension: "mov")
            cell.thumbnailImage!.image = self.generateThumbnail(url!)
            return cell
        }
        
        
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let ds = self.dataStore else {
            return 0
        }
    
        print(ds.cv_numberOfRowsInSection(section))
            
        return ds.cv_numberOfRowsInSection(section) + 1
    }
    
}

extension ScreenzViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        print("Stil updating focus \(indexPath)")
       // self.focusedIndexPath = indexPath
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
            print("We updating path now")
        if let path = context.nextFocusedIndexPath {
            self.focusedIndexPath = path
        }
        self.screenInfoView?.screen = self.dataStore?.cv_objectForRowAtIndexPath(self.focusedIndexPath!) as? Screen
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row >= self.dataStore!.screens.count {
            
            print("Time to restore purchases")
            self.iapHelper?.restorePurchases()
            return
        }
    
        self.playObject = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) as? Screen
        
        if let purchased = self.dataStore?.isScreenPurchased(self.playObject!) {
            if purchased {
                self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
            } else {
                let alert = UIAlertController()
                alert.title = "Purchase"
                alert.message = "Would you like to buy this video?"
                alert.addAction(UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    print("Time to buy")
                    if let ds = self.dataStore {
                        if let product = ds.productForProductId((ds.cv_objectForRowAtIndexPath(indexPath) as! Screen).productId!) {
                            print(product)
                            self.iapHelper?.buyProduct(product)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                    print("Cancel")
                }))
                self.showDetailViewController(alert, sender: nil)
            }
        } else {
            self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)

        }
    }
    
    
}

