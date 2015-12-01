//
//  ApiService.swift
//  Screenz
//
//  Created by Kyle Kirkland on 11/16/15.
//  Copyright © 2015 Kyle Kirkland. All rights reserved.
//

import Foundation

class ApiService {
    
    private var dev = true
    
    private let baseUrl = "http://screenz.herokuapp.com"
    
    static let sharedInstance = ApiService()
    
    func apiGetRequest(path: String, onCompletion: (JSON, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
    
    func getPopularTVShows(onCompletion: (JSON, NSError?) -> Void) {
        apiGetRequest(baseUrl + "/videos.json", onCompletion: { json, err in
            print(json)
            onCompletion(json as JSON, err as NSError?)
        })
    }
}