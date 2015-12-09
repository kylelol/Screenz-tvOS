//
//  ScreenzPlayerViewController.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/5/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import AVKit

class ScreenzPlayerViewController: UIViewController {
    
    var screen: Screen?
    var secondPlayer: AVPlayerItem?
    var firstPlayer: AVPlayerItem?
    var videoURL: NSURL!
    
    var bgVideoURL: NSURL?
    var backgroundPlayer: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newVideo()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.backgroundPlayer!.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newVideo() {
        let url = NSBundle.mainBundle().URLForResource(screen!.url, withExtension: "mov")
        let playerItem = AVPlayerItem(URL: url!)
        
        let tAsset = AVURLAsset(URL: url!)
        let tEditRange = CMTimeRangeMake(CMTimeMake(0,1), CMTimeMake(tAsset.duration.value, tAsset.duration.timescale))
        let tComposition = AVMutableComposition()
        for i in 0...2 {
            try! tComposition.insertTimeRange(tEditRange, ofAsset: tAsset, atTime: tComposition.duration)
        }
        
        let tAVPlayerItem = AVPlayerItem(asset: tComposition)
        
        self.backgroundPlayer = AVPlayer(playerItem: tAVPlayerItem)
        let playerLayer = AVPlayerLayer(player: self.backgroundPlayer)
        
        playerLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer.insertSublayer(playerLayer, atIndex: 0)
        self.backgroundPlayer!.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoLoop", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.backgroundPlayer!.currentItem)
        
    }
    
    func videoLoop() {
        
        self.backgroundPlayer?.pause()
        self.backgroundPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.backgroundPlayer?.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
