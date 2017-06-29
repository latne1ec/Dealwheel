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

open class DataManager {
    
    static var GROUPON_CLIENT_ID = "b0263e3535891104b3e08a32a8061a34daafab74"
    public static var minPointsToSpinPrizewheel = 10
    
    fileprivate static let _instance = DataManager()
    static var Instance: DataManager {
        return _instance
    }
    
    open var currentWedgeColor: Int!
    open var merchantName: String?
    open var dealPrice: String?
    open var dealPointValue: Int?
    open var dealTitle: String?
    open var dealUrlString: String?
    open var dealImageUrlString: String?
    open var prizes = ["$5 Cash", "$10 Cash", "$15 Cash"]
    
    open func getDeal (_ url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                
                let json = JSON(data: data!)
                
                if let dealPrice = json["deals"][0]["options"][0]["price"]["formattedAmount"].string {
                    self.dealPrice = self.getPrice(priceString: dealPrice)
                }
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
    
    func getPrice (priceString: String) -> String {
        var thePricestring = priceString
        if let startIndex = thePricestring.range(of:".")?.lowerBound {
            thePricestring = thePricestring.substring(to: startIndex)
            thePricestring = thePricestring.replacingOccurrences(of: "$", with: "")
        }
        
        if let price = Int(thePricestring) {
            self.dealPointValue = price / 10
        }
        
        return thePricestring
        
    }
    
    func detectIfUserMadePurchase () {
        
        let urlString = String(format:"https://partner-api.groupon.com/reporting/v2/order.json?clientId=%@&group=TopCategory&date=[2017-01-01&date=2017-12-31]&campaign.currency=USD&order.sid=%@", DataManager.GROUPON_CLIENT_ID,  (PFUser.current()?.objectId)!)
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                 // Check if there is a sale with SID same as User Id
                let json = JSON(data: data!)
                //print(json["records"])
                
                //PFUser.current()?.setObject(0, forKey: "grossSales")
                //PFUser.current()?.saveInBackground()
                
                // Check Gross Sales and see if it's greater than current gross sales in DB
                if let grouponGrossSales = json["records"][0]["measures"]["SaleGrossAmount"].double {
                    let userGrossSales = PFUser.current()?.object(forKey: "grossSales") as? Double
                    print("Groupon Gross: \(grouponGrossSales)")
                    print("User Gross: \(userGrossSales!)")
                    if userGrossSales != nil {
                        if grouponGrossSales > userGrossSales! {
                            
                            // Get the last purchase sale amount
                            let lastPurchaseSalePrice = grouponGrossSales - userGrossSales!
                            
                            // Increment user points by rounded difference
                            var currentSalePointValue = lastPurchaseSalePrice.rounded() / 10
                            currentSalePointValue = currentSalePointValue.rounded(.up)
                            print(currentSalePointValue)
                            self.incrementUserPoints(amount: Int(currentSalePointValue))
                            
                            // Update user Sales Gross
                            self.incrementUserGrossSales (amount: lastPurchaseSalePrice)
                            
                        }
                    }
                }
                
                // Check number of purchases and see if greater than current number in DB
                if let totalNumberOfPurchases = json["total"].int {
                    let numberOfPurchasesInDB = PFUser.current()?.object(forKey: "numberOfPurchases") as? Int
                    if totalNumberOfPurchases > numberOfPurchasesInDB! {
                        // User made another purchase! Give them Points and Increment number of Purchases
                        self.incrementNumberOfPurchases()
                    }
                }
                
            }
        }).resume()
    }
    

    // MARK - User Points/Purchases/Sales Related
    
    func incrementUserGrossSales (amount: Double) {
        if PFUser.current() != nil {
            var currentGrossSales = PFUser.current()?.object(forKey: "grossSales") as? Double
            currentGrossSales = currentGrossSales! + amount
            PFUser.current()?.setObject(NSNumber(value:currentGrossSales!), forKey: "grossSales")
            PFUser.current()?.saveInBackground()
        }
    }

    
    func incrementUserPoints (amount: Int) {
        if PFUser.current() != nil {
            var numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            numberOfPoints = numberOfPoints! + amount
            print("Updating user points by \(amount)")
            PFUser.current()?.setObject(NSNumber(value:numberOfPoints!), forKey: "points")
            PFUser.current()?.saveInBackground()
        }
    }
    
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
            numberOfPoints = numberOfPoints! - DataManager.minPointsToSpinPrizewheel
            PFUser.current()?.setObject(NSNumber(value:numberOfPoints!), forKey: "points")
            PFUser.current()?.saveInBackground()
        }
    }
    
    // MARK - Get a Random Prize
    
    func getRandomPrize () -> String {
        
        let randomIndex = Int(arc4random_uniform(UInt32(100)))
        switch randomIndex {
        case 0...98:
            return prizes[0]
        case 99:
            return prizes[1]
        case 100:
            return prizes[2]
        default:
            return ""
        }
    }
}
