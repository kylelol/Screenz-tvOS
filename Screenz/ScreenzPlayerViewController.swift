//
//  ScreenzPlayerViewController.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/5/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import AVKit

class ScreenzPlayerViewController: AVPlayerViewController {
    
    var secondPlayer: AVPlayerItem?
    var firstPlayer: AVPlayerItem?
    var videoURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.player?.actionAtItemEnd = .None
        self.secondPlayer = AVPlayerItem(URL: videoURL)
        self.firstPlayer = AVPlayerItem(URL: videoURL)
   
        weak var w = self
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { (notification) -> Void in
            let queuePlayer = w!.self.player! as! AVQueuePlayer
            if(queuePlayer.currentItem == self.firstPlayer!) {
                queuePlayer.insertItem(self.secondPlayer!, afterItem: nil)
                self.firstPlayer!.seekToTime(kCMTimeZero)
            } else {
                queuePlayer.insertItem(self.firstPlayer!, afterItem: nil)
                self.secondPlayer!.seekToTime(kCMTimeZero)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
