//
//  BeaconEvent.swift
//  AppCMS
//
//  Created by Gaurav Vig on 16/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
class BeaconEvent: NSObject {
    
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
    
    subscript(key: String) -> String {
        get {
            return self.value(forKey: key) as! String
        }
        set {
            self.setValue(newValue, forKey: key)
        }
    }
    
    var aid:String?
    var cid:String?
    var pfm:String?
    var vid:String?
    var uid:String?
    var profid:String?
    var pa:String?
    var player:String?
    var environment:String?
    var media_type:String?
    var tstampoverride:String?
    var stream_id:String?
    var dp1 : String?
    var dp2 : String?
    var dp3 : String?
    var dp4 : String?
    var dp5 : String?
    var ref:String?
    var apos:String?
    var apod:String?
    var vpos:String?
    var url: String?
    var embedurl : String?
    var ttfirstframe : String?
    var bitrate : String?
    var connectionspeed : String?
    var resolutionheight : String?
    var resolutionwidth : String?
    var bufferhealth : String?
    
    init(_ beaconDictionary: Dictionary<String,String>) {
        super.init()
        
        for key in self.propertyNames() {
            if let value = beaconDictionary[key] {
                self[key] = value
            } else {
                self[key] = ""
            }
        }
        //Common values
        self.aid = AppConfiguration.sharedAppConfiguration.beaconObject?.siteName
        self.cid = AppConfiguration.sharedAppConfiguration.beaconObject?.clientId
        
        #if os(iOS)
            self.pfm = "iOS"
        #else
            self.pfm = "appletv"
        #endif
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.uid = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String
        }
        else {
            self.uid = Utility.sharedUtility.getUUID()
        }
        
        self.environment = Utility.sharedUtility.getEnvironment()
    }
    
    class func getParameterDictionary(beaconEvent:BeaconEvent) -> (Dictionary<String,String>) {
        //Dictionary
        
        var beaconDictionary : Dictionary<String,String> = [:]
        for key in beaconEvent.propertyNames() {
            if(beaconEvent[key] != "")
            {
                beaconDictionary[key]=beaconEvent[key]
            }
            
        }
        return beaconDictionary
    }
    
    // MARK : Generate URL
    ///This method generate url of current film by
    ///appending movie name and base URL
    /// - Parameter movieName: movieName description
    /// - Returns:movie url
    class func generateURL(movieName : String) -> String
    {
        var movieUrl = "https://" + AppConfiguration.sharedAppConfiguration.domainName!
        movieUrl = movieUrl+"/films/title/"+movieName
        return movieUrl
    }
    
    // MARK : GET Current TimeStamp
    /// This method returns Current Time Stamp.
    ///
    /// - Returns: current time stamp in string format
    class func getCurrentTimeStamp()->String
    {
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if (reachability.currentReachabilityStatus() == NotReachable) {
            
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let myString = formatter.string(from: Date())
            // convert your string to date
            let yourDate = formatter.date(from: myString)
            //then again set the date format whhich type of output you need
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.init(abbreviation: "UTC")
            // again convert your date to string
            let currentTimeStamp = formatter.string(from: yourDate!)
            return currentTimeStamp
        }
        return ""
    }
}

