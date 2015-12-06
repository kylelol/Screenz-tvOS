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
    var focusGuide: UIFocusGuide!

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var screenInfoView: ScreenInfoView?
    @IBOutlet weak var bgImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configureCollectionView()
        
        ApiService.sharedInstance.getPopularTVShows { (JSON, error) -> Void in
            self.dataStore?.batchAddScreens(Screen.screensWithJsonData(JSON.arrayValue))
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.reloadData()
            })
            self.startBgVideo()


            
        }
        
        iapHelper?.requestProducts({ (products) -> () in
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
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handlePurchaseNotification:", name: IAPHelper.IAPHelperPurchaseNotification, object: nil)
    }
    
    func startBgVideo() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let object = self.dataStore?.cv_objectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            if object is Screen {
                self.screenInfoView!.screen = object as? Screen
                let player = AVPlayer(URL: NSURL(string: (object as! Screen).url)!)
                self.playerViewController = AVPlayerViewController()
                self.playerViewController!.player = player
                self.playerViewController!.showsPlaybackControls = false
                self.playerViewController!.view.frame = UIScreen.mainScreen().bounds
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.view.addSubview(self.playerViewController!.view)
                    self.view.sendSubviewToBack(self.playerViewController!.view)
                    self.playerViewController!.view.userInteractionEnabled = false
                    self.playerViewController!.player?.play()
                })
            }
        }
    }
    
    func swapBgVideoWithScreen(screen: Screen?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
        
            if let screen = screen {
                self.screenInfoView!.screen = screen
                let player = AVPlayer(URL: NSURL(string: screen.url)!)
                
                let newPVC = AVPlayerViewController()
                newPVC.player = player
                newPVC.showsPlaybackControls = false
                newPVC.view.frame = UIScreen.mainScreen().bounds
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.playerViewController?.player?.pause()
                    self.playerViewController?.view.removeFromSuperview()

                    self.view.addSubview(newPVC.view)
                    self.view.sendSubviewToBack(newPVC.view)
                    newPVC.view.userInteractionEnabled = false
                    newPVC.player?.play()
                    self.playerViewController = newPVC
                })
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

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
        
        if segue.identifier == "ScreenPlayerSegue" {
            print("\(playObject!.url)")
            let player = AVPlayer(URL: NSURL(string: playObject!.url)!)
            (segue.destinationViewController as! ScreenzPlayerViewController).player = player
            (segue.destinationViewController as! ScreenzPlayerViewController).videoURL =  NSURL(string: playObject!.url)!

            (segue.destinationViewController as! AVPlayerViewController).player?.play()

        }
    }
    
    func handlePurchaseNotification(notification: NSNotification) {
        if let transaction = notification.object as? SKPaymentTransaction
            where transaction.payment.productIdentifier == VibesPurchase.TestPurchase.productId {
                print(transaction.payment.productIdentifier)

                print("Time to give them there purchase")
                
                //TODO: Receipt validation and serving the content.
                
        } else if let productId = notification.object as? String {
        }
        
    }
    

}

extension ScreenzViewController: ScreenInfoViewDelegate {
    
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
        self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
        
    }
    
    func didTapPreviewButton(infoView: ScreenInfoView) {
        
        self.swapBgVideoWithScreen(infoView.screen)
    }
    
    func priceForButton(productId: String) -> SKProduct? {
        return self.dataStore?.productForProductId(productId)
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ScreenzCell", forIndexPath: indexPath) as! ScreenCollectionViewCell
        
        if let screen = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) {
            cell.thumbnailImage!.image = self.generateThumbnail(NSURL(string:(screen as! Screen).url)!)
        }
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let ds = self.dataStore else {
            return 0
        }
    
        print(ds.cv_numberOfRowsInSection(section))
            
        return ds.cv_numberOfRowsInSection(section)
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
        self.playObject = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) as? Screen
        self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
    }
    
    
}

