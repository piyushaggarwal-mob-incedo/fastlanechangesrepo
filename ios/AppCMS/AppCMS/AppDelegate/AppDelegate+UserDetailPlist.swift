//
//  AppDelegate+UserDetailPlist.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    /**
     Method to create or update plist
     */
    func updateOrCreatePlist() {
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            let fileManager:FileManager = FileManager.default
            let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath:String = documentDirectoryPath.appending("/\(Constants.kUserDetailsPlistName).plist")
            
            if fileManager.fileExists(atPath: filePath) {
                
                let plistDictionary = NSDictionary(dictionary: self.updateUserDefaultPlist())
                
                if plistDictionary.count > 0 {
                    
                    plistDictionary.write(toFile: filePath, atomically: true)
                }
            }
            else {
                
                self.removePlistFromDocumentDirectory(plistName: Constants.kUserDetailsPlistName)
                
                let plistDictionary = NSDictionary(dictionary: self.updateUserDefaultPlist())
                
                if plistDictionary.count > 0 {
                    
                    let plistData:Data = NSKeyedArchiver.archivedData(withRootObject: plistDictionary)
                    fileManager.createFile(atPath: filePath, contents: plistData, attributes: nil)
                }
            }
            
            let transactionInfoFilePath:String = documentDirectoryPath.appending("/\(Constants.kTransactionDetailPlistName).plist")
            
            if fileManager.fileExists(atPath: transactionInfoFilePath) {
                
                let plistDictionary = NSDictionary(dictionary: self.updateTransactionPlist())
                
                if plistDictionary.count > 0 {
                    
                    plistDictionary.write(toFile: transactionInfoFilePath, atomically: true)
                }
            }
            else {
                
                self.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                
                let plistDictionary = NSDictionary(dictionary: self.updateTransactionPlist())
                
                if plistDictionary.count > 0 {
                    
                    let plistData:Data = NSKeyedArchiver.archivedData(withRootObject: plistDictionary)
                    fileManager.createFile(atPath: transactionInfoFilePath, contents: plistData, attributes: nil)
                }
            }
        }
    }
    
    
    /**
     Method to update user defaults on plist and save it on document directory
     */
    func updateUserDefaultPlist() -> Dictionary<String, Any> {
        
        var userDefaultDict:Dictionary<String, Any> = [:]
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            
            userDefaultDict[Constants.kUSERID] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) != nil {
            
            userDefaultDict[Constants.kLoginType] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUpdateSubscriptionStatusToServer) != nil {
            
            userDefaultDict[Constants.kUpdateSubscriptionStatusToServer] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUpdateSubscriptionStatusToServer)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil {
            
            userDefaultDict[Constants.kIsSubscribedKey] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUserOnlineTime) != nil {
            
            userDefaultDict[Constants.kUserOnlineTime] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUserOnlineTime)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: "AppVersionReleaseDate") != nil {
            
            userDefaultDict["AppVersionReleaseDate"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: "AppVersionReleaseDate")
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) != nil {
            
            userDefaultDict[Constants.kAutoPlay] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) != nil {
            
            userDefaultDict[Constants.kCellularDownload] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.RESUME_DOWNLOAD) != nil {
            
            userDefaultDict[Constants.RESUME_DOWNLOAD] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.RESUME_DOWNLOAD)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: "versionOfApp") != nil {
            
            userDefaultDict["versionOfApp"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: "versionOfApp")
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
            
            userDefaultDict[Constants.kAuthorizationToken] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kRefreshToken) != nil {
            
            userDefaultDict[Constants.kRefreshToken] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kRefreshToken)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey) != nil {
            
            userDefaultDict[Constants.kDownloadQualitySelectionkey] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationTokenTimeStamp) != nil {
            
            userDefaultDict[Constants.kAuthorizationTokenTimeStamp] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationTokenTimeStamp)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsAccountLinked) != nil {
            
            userDefaultDict[Constants.kIsAccountLinked] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsAccountLinked)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kFirstTimeUserKey) != nil {
            
            userDefaultDict[Constants.kFirstTimeUserKey] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kFirstTimeUserKey)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled) != nil {
            
            userDefaultDict[Constants.kIsCCEnabled] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadCellularSelectionkey) != nil {
            
            userDefaultDict[Constants.kDownloadCellularSelectionkey] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadCellularSelectionkey)
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kStrUserSubscribed) != nil {
            
            userDefaultDict[Constants.kStrUserSubscribed] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kStrUserSubscribed)
        }
        
        return userDefaultDict
    }
    
    
    /**
     Method to update transaction details on plist and save it on document directory
     */
    func updateTransactionPlist() -> Dictionary<String, Any> {
        
        var transactionInfoDict:Dictionary<String, Any> = [:]
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil {
            
            var transactionInfoDetails:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
            
            if transactionInfoDetails?["transactionId"] != nil {
                
                transactionInfoDict["transactionId"] = transactionInfoDetails?["transactionId"]
            }
            
            if transactionInfoDetails?["planId"] != nil {
                
                transactionInfoDict["planId"] = transactionInfoDetails?["planId"]
            }
            
            if transactionInfoDetails?["success"] != nil {
                
                transactionInfoDict["success"] = transactionInfoDetails?["success"]
            }
            
            if transactionInfoDetails?["productIdentifier"] != nil {
                
                transactionInfoDict["productIdentifier"] = transactionInfoDetails?["productIdentifier"]
            }
            
            if transactionInfoDetails?["receiptData"] != nil {
                
                transactionInfoDict["receiptData"] = transactionInfoDetails?["receiptData"]
            }
        }
        
        return transactionInfoDict
    }
    
    
    /*
     Remove Userdefault.plist after logout
     @param plistName plistName filem Name
     */
    func removePlistFromDocumentDirectory(plistName:String) {
        
        let fileManager:FileManager = FileManager.default
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath:String = documentDirectoryPath.appending("/\(plistName).plist")
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
    }
    
    
    /*
     Fetch User Defaults from plist and cache it in NSUserDefaults
     */
    func fetchUserDefaultsFromPlist() {
        
        let fileManager:FileManager = FileManager.default
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath:String = documentDirectoryPath.appending("/\(Constants.kUserDetailsPlistName).plist")
        
        if fileManager.fileExists(atPath: filePath) {
            
            let userDefaultDict:Dictionary <String, AnyObject>? = NSDictionary(contentsOfFile: filePath) as? Dictionary <String, AnyObject>
            
            if userDefaultDict != nil {
                
                if userDefaultDict?[Constants.kUSERID] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kUSERID], forKey: Constants.kUSERID)
                }
                
                if userDefaultDict?[Constants.kLoginType] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kLoginType], forKey: Constants.kLoginType)
                }
                
                if userDefaultDict?[Constants.kUpdateSubscriptionStatusToServer] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kUpdateSubscriptionStatusToServer], forKey: Constants.kUpdateSubscriptionStatusToServer)
                }
                
                if userDefaultDict?[Constants.kIsSubscribedKey] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kIsSubscribedKey], forKey: Constants.kIsSubscribedKey)
                }
                
                if userDefaultDict?[Constants.kUserOnlineTime] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kUserOnlineTime], forKey: Constants.kUserOnlineTime)
                }
                
                if userDefaultDict?["AppVersionReleaseDate"] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?["AppVersionReleaseDate"], forKey: "AppVersionReleaseDate")
                }
                
                if userDefaultDict?[Constants.kAutoPlay] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kAutoPlay], forKey: Constants.kAutoPlay)
                }
                
                if userDefaultDict?[Constants.kCellularDownload] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kCellularDownload], forKey: Constants.kCellularDownload)
                }
                
                if userDefaultDict?[Constants.RESUME_DOWNLOAD] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.RESUME_DOWNLOAD], forKey: Constants.RESUME_DOWNLOAD)
                }
                
                if userDefaultDict?["versionOfApp"] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?["versionOfApp"], forKey: "versionOfApp")
                }
                
                if userDefaultDict?[Constants.kAuthorizationToken] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kAuthorizationToken], forKey: Constants.kAuthorizationToken)
                }
                
                if userDefaultDict?[Constants.kRefreshToken] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kRefreshToken], forKey: Constants.kRefreshToken)
                }
                
                if userDefaultDict?[Constants.kDownloadQualitySelectionkey] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kDownloadQualitySelectionkey], forKey: Constants.kDownloadQualitySelectionkey)
                }
                
                if userDefaultDict?[Constants.kAuthorizationTokenTimeStamp] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(userDefaultDict?[Constants.kAuthorizationTokenTimeStamp], forKey: Constants.kAuthorizationTokenTimeStamp)
                }
                
                if userDefaultDict?[Constants.kIsAccountLinked] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kIsAccountLinked], forKey: Constants.kIsAccountLinked)
                }
                
                if userDefaultDict?[Constants.kFirstTimeUserKey] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kFirstTimeUserKey], forKey: Constants.kFirstTimeUserKey)
                }
                
                if userDefaultDict?[Constants.kIsCCEnabled] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kIsCCEnabled], forKey: Constants.kIsCCEnabled)
                }
                
                if userDefaultDict?[Constants.kDownloadCellularSelectionkey] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kDownloadCellularSelectionkey], forKey: Constants.kDownloadCellularSelectionkey)
                }
                
                if userDefaultDict?[Constants.kStrUserSubscribed] != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(userDefaultDict?[Constants.kStrUserSubscribed], forKey: Constants.kStrUserSubscribed)
                }
                
                
                Constants.kSTANDARDUSERDEFAULTS.synchronize()
            }
        }
    }
    
    
    /*
     Fetch User Defaults from plist and cache it in NSUserDefaults
     */
    func fetchTransactionDetailsFromPlist() {
        
        let fileManager:FileManager = FileManager.default
        let documentDirectoryPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath:String = documentDirectoryPath.appending("/\(Constants.kTransactionDetailPlistName).plist")
        
        if fileManager.fileExists(atPath: filePath) {
            
            let transactionDetailsDict:Dictionary <String, AnyObject>? = NSDictionary(contentsOfFile: filePath) as? Dictionary <String, AnyObject>
            
            if transactionDetailsDict != nil {
                
                var transactionInfoDetails:Dictionary<String, Any> = [:]
                
                if transactionDetailsDict?["transactionId"] != nil {
                    
                    transactionInfoDetails["transactionId"] = transactionDetailsDict?["transactionId"]
                }
                
                if transactionDetailsDict?["planId"] != nil {
                    
                    transactionInfoDetails["planId"] = transactionDetailsDict?["planId"]
                }
                
                if transactionDetailsDict?["success"] != nil {
                    
                    transactionInfoDetails["success"] = transactionDetailsDict?["success"]
                }
                
                if transactionDetailsDict?["productIdentifier"] != nil {
                    
                    transactionInfoDetails["productIdentifier"] = transactionDetailsDict?["productIdentifier"]
                }
                
                if transactionDetailsDict?["receiptData"] != nil {
                    
                    transactionInfoDetails["receiptData"] = transactionDetailsDict?["receiptData"]
                }
                
                if transactionInfoDetails.count > 0 {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(transactionInfoDetails, forKey: Constants.kTransactionInfo)
                }
            }
        }
    }
}
