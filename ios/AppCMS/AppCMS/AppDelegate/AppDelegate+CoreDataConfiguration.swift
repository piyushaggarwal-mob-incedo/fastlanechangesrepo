//
//  AppDelegate+CoreDataConfiguration.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import MagicalRecord

extension AppDelegate {
    
    //MARK: Setup core data
    func setCoreDataSetup() {
        
        MagicalRecord.enableShorthandMethods()
        
        let versionOfApplication:String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: "versionOfApp") == nil {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(versionOfApplication, forKey: "versionOfApp")
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            resetCoreDataDB()
        }
        else  if Constants.kSTANDARDUSERDEFAULTS.value(forKey: "versionOfApp") as! String != versionOfApplication {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(versionOfApplication, forKey: "versionOfApp")
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            resetCoreDataDB()
        }
        else {
            
            MagicalRecord.setupAutoMigratingCoreDataStack()
        }
    }
    
    //MARK: Reset core data
    func resetCoreDataDB() {
        
        MagicalRecord.cleanUp()
        let folderPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        
        do {
            let docDirs:Array = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            
            for file:String in docDirs {
                
                try FileManager.default.removeItem(atPath: folderPath.appending(file))
            }
            
            let dbStore:String = MagicalRecord.defaultStoreName()
            MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: dbStore)
        } catch {
            
            print(error.localizedDescription)
        }
        
        defer {
            MagicalRecord.setupAutoMigratingCoreDataStack()
        }
    }
}
