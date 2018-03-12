//
//  NetworkStatus.swift
//  AppCMS
//
//  Created by Gaurav Vig on 01/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Alamofire

class NetworkStatus: NSObject {

    static let sharedInstance = NetworkStatus()

    private override init() {}
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { status in
            
            var isNetworkReachable:Bool = false
            switch status {
                
            case .notReachable:
                isNetworkReachable = false
                print("The network is not reachable")
                
            case .unknown :
                isNetworkReachable = false

                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                isNetworkReachable = true

                print("The network is reachable over the WiFi connection")
                
            case .reachable(.wwan):
                isNetworkReachable = true

                print("The network is reachable over the WWAN connection")
                
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.kNetWorkStatus), object: isNetworkReachable)

        }
        reachabilityManager?.startListening()
    }
    
    func isNetworkAvailable() -> Bool {
        guard let reachabilityMgr = reachabilityManager else {
            return false
        }
        return reachabilityMgr.isReachable
    }
}
