//
//  DataManager.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/13/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import Foundation
import SwiftyJSON

public class DataManager {
    
    private static let _instance = DataManager()
    static var Instance: DataManager {
        return _instance
    }
    
    public var responseDic: Dictionary<String, Any> = ["" : ""]
    public var merchantName: String?
    public var dealTitle: String?
    public var dealUrlString: String?
    public var dealImageUrlString: String?
    
    public func getDeal (url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                
                let json = JSON(data: data!)
                
                self.responseDic = ["merchantName" : "", "dealTitle" : "", "dealImageURL" : "", "dealUrl" : ""]
                
                if let merchantName = json["deals"][0]["merchant"]["name"].string {
                    self.merchantName = merchantName
                }
                if let dealTitle = json["deals"][0]["options"][0]["title"].string {
                    self.responseDic["dealTitle"] = dealTitle
                    self.dealTitle = dealTitle
                }
                if let dealUrlString = json["deals"][0]["dealUrl"].string {
                    self.dealUrlString = dealUrlString
                }
                if let dealImageUrlString = json["deals"][0]["largeImageUrl"].string {
                    self.dealImageUrlString = dealImageUrlString
                }
            }
        }).resume()
    }
}
