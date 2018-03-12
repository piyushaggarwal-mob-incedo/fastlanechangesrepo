//
//  SecondScreenDeviceProvider.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 09/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//
// Description: Provides the devices available for screening/casting/flinging app content.

import UIKit

class SecondScreenDeviceProvider: NSObject {

    static let shared = SecondScreenDeviceProvider()
    
    private let castController = CastController()
    private let rokuDevices = RokuDevices()
    
    private var listOfAvailableDevices = Array<Any>()
    
    func startDeviceScan() {
        self.listOfAvailableDevices.removeAll()
        //Fetch the ROKU devices and append to the master list of devices.
        //        rokuDevices.startRokuDeviceScan { (listOfRokuBoxes) in
        //            if listOfRokuBoxes.count > 0 {
        //                self.listOfAvailableDevices.append(listOfRokuBoxes)
        //            }
        //            print("")
        //        }
        castController.startCastDeviceScan { (listOfCastDevices) in
            self.listOfAvailableDevices.removeAll()
            if listOfCastDevices.count > 0 {
                for device in listOfCastDevices{
                    self.listOfAvailableDevices.append(device)
                }
            }
            print("")
        }
    }
    
    func allAvailableDevices() -> [Any] {
        return self.listOfAvailableDevices
    }
    
    
}
