//
//  BeaconSyncManager.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 23/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class BeaconSyncManager {
    
    var queryManager: BeaconQueryManager?

    static let sharedInstance:BeaconSyncManager = {
        
        let instance = BeaconSyncManager()
        
        return instance
    }()
    
    init() {
        if queryManager == nil {
            queryManager = BeaconQueryManager.sharedInstance
        }
    }
    //MARK:-  Sync Events With Server
    func startSyncingTheEvents(withSuccess success: @escaping (_: Bool) -> Void) {
        let arrayOfBeaconEvents = queryManager?.fetchTheUnsyncronisedBeaconEvents()
        if (arrayOfBeaconEvents != nil) {
            if(!(arrayOfBeaconEvents?.isEmpty)!)
            {
              self.postDataToServer(arrayOfBeaconEvents: arrayOfBeaconEvents!)
            }
        }
    }
    //MARK:-POST data to server
    /// Method to post data to server in form on Array with nested dictionaries
    ///
    /// - Parameter arrayOfBeaconEvents: return Array
    private func postDataToServer(arrayOfBeaconEvents : Array<Dictionary<String,String>>)
    {
        DataManger.sharedInstance.net_postOfflineBeaconEvents(beaconEventArray: arrayOfBeaconEvents) { (response) in
            if(response)
            {
              self.queryManager?.removeBeaconEventFromTheBeaconDB()
            }
        }
    }
}
