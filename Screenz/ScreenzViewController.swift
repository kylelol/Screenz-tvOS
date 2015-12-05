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
    
    var focusedIndexPath: NSIndexPath?
    var playObject: Screen?
    var playerViewController: AVPlayerViewController?

    
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
        
        self.screenInfoView?.delegate = self
    }
    
    func startBgVideo() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let object = self.dataStore?.cv_objectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            if object is Screen {
                self.screenInfoView!.screen = object as? Screen
                let player = AVPlayer(URL: NSURL(string: (object as! Screen).url)!)
             //   self.playerViewController?.player?.pause()
               // self.playerViewController?.view.removeFromSuperview()
                //player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
                //NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ScreenPlayerSegue" {
            let player =
            print("\(playObject!.url)")
            (segue.destinationViewController as! AVPlayerViewController).player = AVPlayer(URL: NSURL(string: playObject!.url)!)
                        (segue.destinationViewController as! AVPlayerViewController).player?.play()

        }
    }
    

}

extension ScreenzViewController: ScreenInfoViewDelegate {
    
    func didTapBuyButton(infoView: ScreenInfoView) {
        
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
            print("Somethign went wrong generating a thumbnail")
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
        
        self.focusedIndexPath = indexPath
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let path = self.focusedIndexPath {
            self.screenInfoView?.screen = self.dataStore?.cv_objectForRowAtIndexPath(path) as? Screen
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.playObject = self.dataStore?.cv_objectForRowAtIndexPath(indexPath) as? Screen
        self.performSegueWithIdentifier("ScreenPlayerSegue", sender: nil)
    }
    
    
}

