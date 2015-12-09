//
//  LoopingPlayer.swift
//  Screenz
//
//  Created by Kyle Kirkland on 12/7/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol LoopingPlayerProgressDelegate: class {
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float)
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool)
}

class LoopingPlayer: AVPlayer {
    
    weak var progressDelegate: LoopingPlayerProgressDelegate?
    
    var loopCount: Double = 0
    var timer: NSTimer?
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    override init(URL url: NSURL!) {
        super.init(URL: url)
        self.commonInit()
    }
    
    override init(playerItem item: AVPlayerItem!) {
        super.init(playerItem: item)
        self.commonInit()
    }
    
    func commonInit() {
        self.addObserver(self, forKeyPath: "currentItem", options: .New, context: nil)
        self.actionAtItemEnd = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"playerDidPlayToEndTimeNotification:", name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"mute", name:"MutePlayers", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"unmute", name:"UnmutePlayers", object:nil)
    }
    
    deinit {
        self.timer?.invalidate()
        self.removeObserver(self, forKeyPath: "currentItem")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func mute() {
        self.volume = 0.0
    }
    
    func unmute() {
        self.volume = 1.0
    }
    
    var playableDuration: CMTime {
        get {
            if let item: AnyObject = self.currentItem?.loadedTimeRanges.first {
                if let timeRange = item.CMTimeRangeValue {
                    let playableDuration = CMTimeAdd(timeRange.start, timeRange.duration)
                    return playableDuration
                }
            }
            return kCMTimeZero
        }
    }
    
    var loadingProgress: Float {
        get {
            if (self.currentItem == nil) {
                self.timer?.invalidate()
                self.progressDelegate?.loopingPlayer(self, didFinishLoading: false)
                return 0
            }
            let playableDurationInSeconds = CMTimeGetSeconds(self.playableDuration)
            let totalDurationInSeconds = CMTimeGetSeconds(self.currentItem!.duration)
            if (totalDurationInSeconds.isNormal) {
                var progress = Float(playableDurationInSeconds / totalDurationInSeconds)
                self.progressDelegate?.loopingPlayer(self, didLoad: progress)
                if (progress > 0.90) {
                    self.progressDelegate?.loopingPlayer(self, didFinishLoading: true)
                    self.timer?.invalidate()
                }
                return progress
            }
            return 0
        }
    }
    
    func playerDidPlayToEndTimeNotification(notification: NSNotification) {
        let playerItem: AVPlayerItem = notification.object as! AVPlayerItem
        if (playerItem != self.currentItem) {
            return
        }
        self.seekToTime(kCMTimeZero)
        self.play()
        loopCount += 1
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentItem" {
            self.timer?.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "loadingProgress", userInfo: nil, repeats: true)
        }
    }
}
