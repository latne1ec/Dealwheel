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
    open var prizes = ["$5 Amazon Giftcard", "$10 Amazon Giftcard", "$15 Amazon Giftcard"]
    
    open func getDeal (_ url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                
                print(url)
                
                let json = JSON(data: data!)
                //print(json["deals"])
                let dealCount = json["deals"].count
                var randomOffset = Int(arc4random_uniform(UInt32(dealCount)))
                //print(json["deals"][randomOffset])
                //print(randomOffset)
                
                if dealCount == 1 {
                    randomOffset = 0
                }
                
                
                if let dealPrice = json["deals"][randomOffset]["options"][0]["price"]["formattedAmount"].string {
                    let updatedDealPrice = dealPrice.replacingOccurrences(of: ",", with: "")
                    self.dealPrice = self.getPrice(priceString: updatedDealPrice)

                }
                if let merchantName = json["deals"][randomOffset]["merchant"]["name"].string {
                    self.merchantName = merchantName
                }
                if let dealTitle = json["deals"][randomOffset]["options"][0]["title"].string {
                    self.dealTitle = dealTitle
                }
                if let announcementTitle = json["deals"][randomOffset]["announcementTitle"].string {
                    self.dealTitle = announcementTitle
                }

                if let dealUrlString = json["deals"][randomOffset]["dealUrl"].string {
                    self.dealUrlString = dealUrlString
                }
                if let dealImageUrlString = json["deals"][randomOffset]["largeImageUrl"].string {
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
        
        if var price = Double(thePricestring) {
            price = price.rounded(.up)
            let this = roundToTens(x: price)
            self.dealPointValue = this / 10
            //self.dealPointValue = Int(price.rounded()) / 10
            if self.dealPointValue! <= 0 {
                self.dealPointValue = 1
            }
        }
        
        return thePricestring
        
    }
    
    func roundToTens(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
    func detectIfUserMadePurchase () {
        
        let urlString = String(format:"https://partner-api.groupon.com/reporting/v2/order.json?clientId=%@&group=TopCategory&date=[2017-01-01&date=2017-12-31]&campaign.currency=USD&order.sid=%@", DataManager.GROUPON_CLIENT_ID,  (PFUser.current()?.objectId)!)
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            } else {
                
                // Get JSON
                let json = JSON(data: data!)
                
                
                // Check User Gross Sales and see if it's greater than current gross sales in DB
                if let grouponGrossSales = json["records"][0]["measures"]["SaleGrossAmount"].double {
                    if let userGrossSales = PFUser.current()?.object(forKey: "grossSales") as? Double {
                        //print("Groupon Gross: \(grouponGrossSales)")
                        //print("User Gross: \(userGrossSales)")
                        if grouponGrossSales > userGrossSales {
                            
                            // Get the last purchase sale amount
                            let lastPurchaseSalePrice = grouponGrossSales - userGrossSales
                            
                            // Increment user points by rounded difference
                            var currentSalePointValue = lastPurchaseSalePrice.rounded() / 10
                            currentSalePointValue = currentSalePointValue.rounded(.up)
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
            PFUser.current()?.saveInBackground(block: { (success, error) in
            })
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
