//
//  ApiService.swift
//  Screenz
//
//  Created by Kyle Kirkland on 11/16/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation
import StoreKit

class ApiService {
    
    private var dev = true
    
   // private let baseUrl = "http://screenz.herokuapp.com"
    private let baseUrl = "http://192.168.0.15:3000"
    
    static let sharedInstance = ApiService()
    
    private func apiGetRequest(path: String, onCompletion: (JSON, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            guard let data = data else {
                print(error)
                return
            }
            let json:JSON = JSON(data: data)
            onCompletion(json, error)
        })
        task.resume()
    }
    
    private func apiPostRequest(path: String, parameters: [String: AnyObject], onCompletion: (NSError?) -> ()) {
        let request  = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.init(rawValue: 0))
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            onCompletion(error)
        }
        task.resume()
    }
    

    func createPurchase(transaction: SKPaymentTransaction, onCompletion: (NSError?) -> ()) {
        
        let params: [String: AnyObject] = ["transaction_id": transaction.transactionState == .Restored ? transaction.originalTransaction!.transactionIdentifier! : transaction.transactionIdentifier!, "product_id": transaction.payment.productIdentifier]
        
        apiPostRequest(baseUrl + "/payments.json", parameters: params) { (error) -> () in
            onCompletion(error)
        }
    }
    
    private func downloadAndStoreMp4Locally(urls: [String], onCompletion: ([String], NSError?) -> ()) {
        
        let group = dispatch_group_create()
        var localPaths = [String]()
        for url in urls {
            dispatch_group_enter(group)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
               print("Starting download for \(url)")
                if let data = NSData(contentsOfURL: NSURL(string: url)!) {
                    let documentsDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
                    let pathComps = url.componentsSeparatedByString("/")
                    let fileName = pathComps[pathComps.count - 1]
                    let filePath = "\(documentsDir)/\(fileName)"
                    print("About to write file to: \(filePath)")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        localPaths.append(filePath)
                        data.writeToFile(filePath, atomically: true)
                        print("File Saved")
                        dispatch_group_leave(group)
                    }
                    
                }
                
            }
        }
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            print("All done downoading videos")
            onCompletion(localPaths, nil)
        }
    }
    
    
    func getPopularTVShows(onCompletion: (JSON, NSError?) -> Void) {
        apiGetRequest(baseUrl + "/videos.json", onCompletion: { json, err in
            print(json)
            var urls = [String]()
            for screen in json.arrayValue {
                urls.append(screen["url"].stringValue)
            }
            
          //  self.downloadAndStoreMp4Locally(urls, onCompletion: { (localPaths, error) -> () in
          //  })
            onCompletion(json as JSON, err as NSError?)

        })
    }
}