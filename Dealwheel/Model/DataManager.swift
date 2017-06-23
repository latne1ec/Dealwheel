//
//  DataManager.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/13/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import Foundation
import SwiftyJSON
import Parse

public class DataManager {
    
    static var GROUPON_CLIENT_ID = "b0263e3535891104b3e08a32a8061a34daafab74"
    
    private static let _instance = DataManager()
    static var Instance: DataManager {
        return _instance
    }
    
    public var currentWedgeColor: Int!
    public var merchantName: String?
    public var dealTitle: String?
    public var dealUrlString: String?
    public var dealImageUrlString: String?
    public var prizes = ["$5 Cash", "$10 Cash", "$15 Cash", "$20 Cash", "$25 Cash", "$30 Cash"]
    
    public func getDeal (url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                
                let json = JSON(data: data!)
                
                if let merchantName = json["deals"][0]["merchant"]["name"].string {
                    self.merchantName = merchantName
                }
                if let dealTitle = json["deals"][0]["options"][0]["title"].string {
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
    
    func detectIfUserMadePurchase () {
        
        let urlString = String(format:"https://partner-api.groupon.com/reporting/v2/order.json?clientId=%@&group=TopCategory&date=[2017-01-01&date=2017-12-31]&campaign.currency=USD&order.sid=%@", DataManager.GROUPON_CLIENT_ID,  (PFUser.current()?.objectId)!)
        let url = URL(string: urlString)
        //print(urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                 // Check if there is a sale with SID same as User Id
                let json = JSON(data: data!)
                //print(json)
                // Check number of purchases and see if greater than current number in DB
                if let totalNumberOfPurchases = json["total"].int {
                    let numberOfPurchasesInDB = PFUser.current()?.object(forKey: "numberOfPurchases") as? Int
                    if totalNumberOfPurchases > numberOfPurchasesInDB! {
                        // User made another purchase! Give them 50 Points and Increment number of Purchases
                        self.incrementNumberOfPurchases()
                        self.addUserPoints()
                    }
                }
                // Increment number of purchases, compare against total number of purchases and
                
                // addUserPoints()
            }
        }).resume()
    }
    
    // MARK - User Points Related
    
    func addUserPoints () {
        if PFUser.current() != nil {
            var numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            numberOfPoints = numberOfPoints! + 50
            PFUser.current()?.setObject(NSNumber(value:numberOfPoints!), forKey: "points")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func incrementNumberOfPurchases () {
        if PFUser.current() != nil {
            var numberOfPurchases = PFUser.current()?.object(forKey: "numberOfPurchases") as? Int
            numberOfPurchases = numberOfPurchases! + 1
            PFUser.current()?.setObject(NSNumber(value:numberOfPurchases!), forKey: "numberOfPurchases")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func deductPointsForPrizeWheelSpin () {
        if PFUser.current() != nil {
            var numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            numberOfPoints = numberOfPoints! - 500
            PFUser.current()?.setObject(NSNumber(value:numberOfPoints!), forKey: "points")
            PFUser.current()?.saveInBackground()
        }
    }
    
    // MARK - Get a Random Prize
    
    func getRandomPrize () -> String {
        
        let randomIndex = Int(arc4random_uniform(UInt32(10)))
        switch randomIndex {
        case 0:
            return prizes[0]
        case 1:
            return prizes[0]
        case 2:
            return prizes[0]
        case 3:
            return prizes[0]
        case 4:
            return prizes[0]
        case 5:
            return prizes[1]
        case 6:
            return prizes[2]
        case 7:
            return prizes[3]
        case 8:
            return prizes[4]
        case 9:
            return prizes[5]
        default:
            return ""
        }
    }
}
