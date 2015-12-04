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
    private let baseUrl = "http://localhost:3000"
    
    static let sharedInstance = ApiService()
    
    private func apiGetRequest(path: String, onCompletion: (JSON, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
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
        
        let params: [String: AnyObject] = ["transaction_id":transaction.transactionIdentifier!, "product_id": transaction.payment.productIdentifier]
        
        apiPostRequest(baseUrl + "/payments.json", parameters: params) { (error) -> () in
            onCompletion(error)
        }
    }
    
    
    func getPopularTVShows(onCompletion: (JSON, NSError?) -> Void) {
        apiGetRequest(baseUrl + "/videos.json", onCompletion: { json, err in
            print(json)
            onCompletion(json as JSON, err as NSError?)
        })
    }
}