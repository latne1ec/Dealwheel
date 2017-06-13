//
//  GrouponAPIManager.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/12/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import Foundation
import SwiftyJSON

public class GrouponAPIManager {
    
    private static let _instance = GrouponAPIManager()
    static var Instance: GrouponAPIManager {
        return _instance
    }
    
//    public func getDeal (url: URL) -> Dictionary {
//        
//        URLSession.shared.dataTask(with: url, completionHandler: {
//            (data, response, error) in
//            if(error != nil){
//                print("error")
//            }else{
//                
//                let json = JSON(data: data!)
//                
//                if let merchantName = json["deals"][0]["merchant"]["name"].string {
//                    print(merchantName)
//                }
//                if let dealTitle = json["deals"][0]["options"][0]["title"].string {
//                    print(dealTitle)
//                }
//                if let dealUrl = json["deals"][0]["dealUrl"].string {
//                    print(dealUrl)
//                }
//                if let dealImageUrl = json["deals"][0]["largeImageUrl"].string {
//                    print(dealImageUrl)
//                }
//                
//                let dic = ["merchantName" : merchant]
//            }
//        }).resume()
//        
//    }

}

