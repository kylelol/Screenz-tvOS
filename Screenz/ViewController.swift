//
//  ViewController.swift
//  Screenz
//
//  Created by Kyle Kirkland on 11/16/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController, IAPContainer, DataStoreOwner {
    
    var iapHelper : IAPHelper?
    
    var dataStore : DataStore? {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }

    
    var data: [JSON]?
    var playerViewController: AVPlayerViewController?
    var focusIndexPath: NSIndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var screenInfoView: ScreenInfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ApiService.sharedInstance.getPopularTVShows { (JSON, error) -> Void in
            self.data = JSON.arrayValue
            self.dataStore?.batchAddScreens(Screen.screensWithJsonData(JSON.arrayValue))
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.configureVideo(0)
            })
            
        }
        
        iapHelper?.requestProducts({ (products) -> () in
            print(products)
            self.dataStore?.batchAddProducts(products)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.playerViewController?.player?.status == AVPlayerStatus.ReadyToPlay {
            print("Appearing")
            self.playerViewController?.player?.play()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureVideo(index: Int) {
        
        if playerViewController != nil {
            playerViewController?.view.removeFromSuperview()
            playerViewController?.removeFromParentViewController()
        }
        
        let player = AVPlayer(URL: NSURL(string: self.data![index]["url"].stringValue)!)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
        print(self.videoView.bounds)
        self.addChildViewController(playerViewController!)
        playerViewController!.view.frame = self.videoView.bounds
        self.videoView.addSubview(playerViewController!.view)
        playerViewController!.player!.play()
    }
    
    func videoDidReachEnd(notification: NSNotification) {
        let p = notification.object as! AVPlayerItem
        p.seekToTime(kCMTimeZero)
    }


}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataStore!.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0: cell = self.configureVideoCellForTableView(tableView, atIndexPath: indexPath)
        case 1: cell = self.configurePurchaseCellForTableView(tableView, atIndexPath: indexPath)
        default: cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
        }

        
        return cell
    }
    
    private func configureVideoCellForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell")! as! VideoTableViewCell
        let video = self.dataStore!.objectForRowAtIndexPath(indexPath) as! Screen
        cell.videoTitleLabel.text = video.title
        
        return cell
        
    }
    
    private func configurePurchaseCellForTableView(tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PurchaseCell")
        
        return cell!
    }
    
    
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Screenz"
        } else {
            return "Available Screenz"
        }
    }
    
    func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        print("indexPath: \(indexPath.row)")
        self.focusIndexPath = indexPath
        return true
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        let object = self.dataStore?.objectForRowAtIndexPath(self.focusIndexPath!)
        if object is Screen {
            self.screenInfoView.screen = object as? Screen
        }
       /* self.playerViewController?.player?.pause()
        self.playerViewController?.view.removeFromSuperview()
        
        let player = AVPlayer(URL: NSURL(string: self.data![self.focusIndexPath!.row]["url"].stringValue)!)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
        playerViewController!.view.frame = self.videoView.bounds
        self.videoView.addSubview(playerViewController!.view)
        playerViewController!.player?.play()*/
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected row")
        //if indexPath.row == 0 {
        self.playerViewController?.player?.pause()
        let player = AVPlayer(URL: NSURL(string: self.data![indexPath.row]["url"].stringValue)!)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        let  playerVC = AVPlayerViewController()
        playerVC.player = player
        print(self.videoView.bounds)
        playerVC.player!.play()
        self.presentViewController(playerVC, animated: true, completion: nil)
            
        //}
    }
}

