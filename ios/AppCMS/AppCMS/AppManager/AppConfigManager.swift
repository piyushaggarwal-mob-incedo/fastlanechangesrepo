//
//  AppConfigManager.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 03/03/17.
//  Copyright © 2017 Abhinav Saldi. All rights reserved.
//

import Foundation

@objc protocol AppConfigManagerDelegate: NSObjectProtocol {
    
    @objc func appConfigurationCompletedWithSuccess(configurationDone: Bool) -> Void;
}

class AppConfigManager: NSObject, AppParserDelegate
{
    private var currentCount = 0, pageCount = 0
    
    weak var appConfigurationDelegate: AppConfigManagerDelegate?
    
    //MARK: Update Folders and Files
    func startConfiguringApp() -> Void {
        
        self.updateApplicationFolders { (Bool) in
            if Bool
            {
                let mainFilePath = AppSandboxManager.getMainFilePath()
                if FileManager.default.fileExists(atPath: mainFilePath)
                {
                   self.configureAppFromPreFetchedFiles()
                }
                else
                {
                    self.updateFilesInApplicationFolder()
                }
            }
            else
            {
                self.finishedConfiguringApp(isAppConfigured: false)
            }
        }
    }
    
    func updateApplicationFolders(foldersUpdated: @escaping((_ isFolderStructureUpdated: Bool) -> Void)) -> Void {
        let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()
        appSandBoxManager.manageAppDocumentDirectoryStructure { (Bool) in
            foldersUpdated(Bool)
        }
    }
    
    func updateFilesInApplicationFolder() -> Void
    {
        let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
        
        let siteId:String = dicRoot["SiteId"] as! String
        let uiJsonBaseUrl:String = dicRoot["UIJsonBaseUrl"] as! String
        
        var apiEndPoint:String = "\(uiJsonBaseUrl)/\(siteId)/main.json?x="
        
        let currentTime = Date().timeIntervalSince1970
        apiEndPoint.append(String(describing: currentTime))
        
        self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
            
            if downloadedJSONData != nil && isSuccess{
                
                if (downloadedJSONData?.count)! > 0
                {
                    self.processAppConfigData(appConfigdata: downloadedJSONData!, result: { (isParsed) in
                        if isParsed //Configuration Passed
                        {
                            //self.finishedConfiguringApp(isAppConfigured: true)
                        }
                        else // Configuration Failed
                        {
                            self.finishedConfiguringApp(isAppConfigured: false)
                        }
                    })
                }
            }
            else //If Data coming as nil
            {
                if AppSandboxManager.getMainFilePath().isEmpty {
                    
                    self.finishedConfiguringApp(isAppConfigured: false)
                }
                else {
                    
                    let appConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!)
                    if let appDictionary = appConfigJson as? [String: Any] {
                        let appParser = AppParser()
                        appParser.appParserDelegate = self
                        //appParser.parseAppMainConfigurationJson(appConfigDictionary:appDictionary as Dictionary<String, AnyObject>)
                        
                        appParser.parseAppMainConfigurationJson(appConfigDictionary: appDictionary as Dictionary<String, AnyObject>, methodCallback: { (iOSJsonUrl: String?) in
                            
                            if iOSJsonUrl != nil {
                                self.configuringiOSJson(apiURL: iOSJsonUrl!)
                            }
                        })
                    }
                    else {
                        
                        self.finishedConfiguringApp(isAppConfigured: false)
                    }
                }
                //self.finishedConfiguringApp(isAppConfigured: false)
            }
        }
    }
    
        
    func configuringiOSJson(apiURL:String) -> Void
    {
        var apiEndPoint:String = "\(apiURL)?x="
        
        if AppConfiguration.sharedAppConfiguration.configFileTimestamp != nil {
            
            apiEndPoint.append(String(describing: AppConfiguration.sharedAppConfiguration.configFileTimestamp!))
        }
        
        if Constants.kAPPDELEGATE.isVersionChanged {
            self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                
                if downloadedJSONData != nil {
                    
                    if (downloadedJSONData?.count)! > 0
                    {
                        self.processiOSConfigData(iOSConfigdata: downloadedJSONData!, result: { (isParsed) in
                            if isParsed //Configuration Passed
                            {
                                self.downloadAndSavePagesJsonFiles()
                            }
                            else // Configuration Failed
                            {
                                self.finishedConfiguringApp(isAppConfigured: false)
                            }
                        })
                    }
                }
                else //If Data coming as nil
                {
                    self.finishedConfiguringApp(isAppConfigured: false)
                }
            }
        }
        else
        {
            //guard is used as  app was crashing in case of search file is not available due to any reason at destination path.
            guard let iOSFileData: Data = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath()) else { return }
            //let iOSFileData: Data = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!
            
            if (iOSFileData.count) > 0
            {
                self.processiOSConfigData(iOSConfigdata: iOSFileData, result: { (isParsed) in
                    if isParsed //Configuration Passed
                    {
                        self.downloadAndSavePagesJsonFiles()
                    }
                    else // Configuration Failed
                    {
                        self.finishedConfiguringApp(isAppConfigured: false)
                    }
                })
            }
            else {
                
                self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                    
                    if downloadedJSONData != nil {
                        
                        if (downloadedJSONData?.count)! > 0
                        {
                            self.processiOSConfigData(iOSConfigdata: downloadedJSONData!, result: { (isParsed) in
                                if isParsed //Configuration Passed
                                {
                                    self.downloadAndSavePagesJsonFiles()
                                }
                                else // Configuration Failed
                                {
                                    self.finishedConfiguringApp(isAppConfigured: false)
                                }
                            })
                        }
                    }
                    else //If Data coming as nil
                    {
                        self.finishedConfiguringApp(isAppConfigured: false)
                    }
                }
            }
        }
    }
    
    func configuringPageJson(pageJsonURL:String, pageName: String) -> Void
    {
        var apiEndPoint:String = "\(pageJsonURL)?x="
        
        if AppConfiguration.sharedAppConfiguration.configFileTimestamp != nil {
            
            apiEndPoint.append(String(describing: AppConfiguration.sharedAppConfiguration.configFileTimestamp!))
        }
        
        if Constants.kAPPDELEGATE.isVersionChanged {
            self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                
                if downloadedJSONData != nil {
                    if (downloadedJSONData?.count)! > 0
                    {
                        self.processPageConfigData(pageConfigdata: downloadedJSONData!, jsonPageName: pageName, result: { (Bool) in
                            self.currentCount = self.currentCount + 1
                            if self.currentCount == self.pageCount
                            {
                                self.finishedConfiguringApp(isAppConfigured: true)
                            }
                        })
                    }
                }
                else //If Data coming as nil
                {
                    self.currentCount = self.currentCount + 1
                    if self.currentCount == self.pageCount
                    {
                        self.finishedConfiguringApp(isAppConfigured: false)
                    }
                }
            }
        }
        else
        {
            let pageData: Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: pageName))
            
            if pageData != nil {
                
                if (pageData?.count)! > 0
                {
                    self.processPageConfigData(pageConfigdata: pageData!, jsonPageName: pageName, result: { (Bool) in
                        self.currentCount = self.currentCount + 1
                        if self.currentCount == self.pageCount
                        {
                            self.finishedConfiguringApp(isAppConfigured: true)
                        }
                    })
                }
            }
            else {
                
                self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                    
                    if downloadedJSONData != nil {
                        if (downloadedJSONData?.count)! > 0
                        {
                            self.processPageConfigData(pageConfigdata: downloadedJSONData!, jsonPageName: pageName, result: { (Bool) in
                                self.currentCount = self.currentCount + 1
                                if self.currentCount == self.pageCount
                                {
                                    self.finishedConfiguringApp(isAppConfigured: true)
                                }
                            })
                        }
                    }
                    else //If Data coming as nil
                    {
                        self.currentCount = self.currentCount + 1
                        if self.currentCount == self.pageCount
                        {
                            self.finishedConfiguringApp(isAppConfigured: false)
                        }
                    }
                }
            }
        }
    }
    
    
    func downloadAndSavePagesJsonFiles() -> Void
    {
        
    }
    
    
    // Function to respond back if application is successful or not
    func finishedConfiguringApp(isAppConfigured: Bool) -> Void {
        if appConfigurationDelegate != nil && (appConfigurationDelegate?.responds(to: #selector(AppConfigManagerDelegate.appConfigurationCompletedWithSuccess)))! {
            appConfigurationDelegate?.appConfigurationCompletedWithSuccess(configurationDone: isAppConfigured)
        }
    }
    
    init(appConfigurationDelegate: AppConfigManagerDelegate) {
        self.appConfigurationDelegate = appConfigurationDelegate
    }
    
    private
    func downloadConfigurationFile(apiURL:String, appConfigJSONData: @escaping ((_ downloadedJSONData: Data?, _ isSuccess:Bool) -> Void)) -> Void {

        NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: apiURL) { (responseConfigData: Data?, isSuccess:Bool) in
            if responseConfigData != nil && isSuccess
            {
                appConfigJSONData(responseConfigData!, true)
            }
            else  {
                
                let filePath = AppSandboxManager.getMainFilePath()
                var appConfigJson : Data
                if filePath.isEmpty == false {
                    appConfigJson = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!
                    appConfigJSONData(appConfigJson, true)
                } else {
                    appConfigJSONData(nil, false)
                }
            }
        }
    }
    
    func processAppConfigData(appConfigdata: Data, result: ((_ isParsed: Bool) -> Void)) -> Void
    {
        let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()
        
        if self.checkVersionOfFileFromDownloadedContent(downloadedContentData: appConfigdata, currentSavedFilePath: AppSandboxManager.getMainFilePath()) {
            Constants.kAPPDELEGATE.isVersionChanged = true
            
            appSandBoxManager.updateMainFile(fileData: appConfigdata) { (Bool) in
                let appConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!)
                if let appDictionary = appConfigJson as? [String: Any] {
                    let appParser = AppParser()
                    appParser.appParserDelegate = self
                    //appParser.parseAppMainConfigurationJson(appConfigDictionary:appDictionary as Dictionary<String, AnyObject>)
                    
                    appParser.parseAppMainConfigurationJson(appConfigDictionary: appDictionary as Dictionary<String, AnyObject>, methodCallback: { (iOSJsonUrl: String?) in
                        
                        if iOSJsonUrl != nil {
                            self.configuringiOSJson(apiURL: iOSJsonUrl!)
                        }
                        else {
                            //Need to handle this
                            self.finishedConfiguringApp(isAppConfigured: false)
                        }
                    })
                }
            }
        }
        else
        {
            let appConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!)
            if let appDictionary = appConfigJson as? [String: Any] {
                let appParser = AppParser()
                appParser.appParserDelegate = self
                //appParser.parseAppMainConfigurationJson(appConfigDictionary:appDictionary as Dictionary<String, AnyObject>)
                
                appParser.parseAppMainConfigurationJson(appConfigDictionary: appDictionary as Dictionary<String, AnyObject>, methodCallback: { (iOSJsonUrl: String?) in
                    
                    if iOSJsonUrl != nil {
                        self.configuringiOSJson(apiURL: iOSJsonUrl!)
                    }
                })
            }
        }
    }
    
    
    
    
    func processiOSConfigData(iOSConfigdata: Data, result: @escaping ((_ isParsed: Bool) -> Void)) -> Void
    {
        if self.checkVersionOfFileFromDownloadedContent(downloadedContentData: iOSConfigdata, currentSavedFilePath: AppSandboxManager.getPlatformJSONFilePath()) {
            
            fetchiOSJsonData(iOSConfigdata: iOSConfigdata, result: result)
        }
        else
        {
            
            let iOSConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!)
            
            if let iOSDictionary = iOSConfigJson as? [String: Any] {
                let appParser = AppParser()
                appParser.appParserDelegate = self
                appParser.parseiOSConfigurationJson(iOSConfigDictionary: iOSDictionary as Dictionary<String, AnyObject>,
                                                    iOSConfigJsonCallback:
                    { (Array) in
                        self.pageCount = Array.count
                        
                        if self.pageCount == 0 {
                            
                            self.fetchiOSJsonData(iOSConfigdata: iOSConfigdata, result: result)
                            //self.finishedConfiguringApp(isAppConfigured: true)
                        }
                        else {
                            
                            for var pageDictionary in Array as! [Dictionary<String, AnyObject>]
                            {
                                self.configuringPageJson(pageJsonURL: pageDictionary["Page-UI"] as! String, pageName: pageDictionary["Page-ID"] as! String)
                            }
                        }
                        
                },
                                                    iOSConfigPlistCallback:
                    { (Dictionary) in
                        
                }
                )
            }
        }
    }
    
    
    
    func fetchiOSJsonData(iOSConfigdata: Data, result: @escaping ((_ isParsed: Bool) -> Void)) {
        
        let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()

        appSandBoxManager.updatePlatformJSONFile(fileData: iOSConfigdata) { (Bool) in
            let iOSConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!)
            
            if let iOSDictionary = iOSConfigJson as? [String: Any] {
                let appParser = AppParser()
                appParser.appParserDelegate = self
                appParser.parseiOSConfigurationJson(iOSConfigDictionary: iOSDictionary as Dictionary<String, AnyObject>,
                                                    iOSConfigJsonCallback:
                    { (Array) in
                        if AppConfiguration.sharedAppConfiguration.modulesUIBlock != nil
                        {
                            if AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl != nil
                            {
                                var moduleUIURL: String = (AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl)!
                                moduleUIURL.append("?version=\(AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIVersion ?? "0")")
                                
                                NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: moduleUIURL) { (jsonData, isSuccess) in
                                    
                                    if jsonData != nil && isSuccess
                                    {
                                        self.processUIBlockConfigData(moduleUIdata: jsonData!, result: { (success) in
                                            let blockJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))!)
                                            if let blockDict = blockJson as? [String: Any]
                                            {
                                                PageUIBlocks.sharedInstance.parseBlockComponents(blockDict: blockDict)
                                            }
                                        })
                                        
                                    }
                                    self.pageCount = Array.count
                                    if Array.isEmpty == false {
                                        for var pageDictionary in Array as! [Dictionary<String, AnyObject>]
                                        {
                                            self.configuringPageJson(pageJsonURL: pageDictionary["Page-UI"] as! String, pageName: pageDictionary["Page-ID"] as! String)
                                        }
                                    } else {
                                        self.finishedConfiguringApp(isAppConfigured: false)
                                    }
                                }
                            }
                        }
                        
                        
                },
                                                    iOSConfigPlistCallback:
                    { (Dictionary) in
                        let plistData = NSDictionary(dictionary: Dictionary)
                        AppSandboxManager.updatePlatformPlist(platformPlistDictionary: plistData)
                }
                )
            }
        }
    }
    
    
    func processPageConfigData(pageConfigdata: Data, jsonPageName: String, result: @escaping ((_ isParsed: Bool) -> Void)) -> Void
    {
        let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()
        
        if self.checkVersionOfFileFromDownloadedContent(downloadedContentData: pageConfigdata, currentSavedFilePath: AppSandboxManager.getpageFilePath(fileName: jsonPageName)) {
            appSandBoxManager.updatePagesJSONFile(fileName: jsonPageName, fileData: pageConfigdata, platformJSONFileCallback: { (Bool) in
                result(true)
            })
        }
        else
        {
            result(true)
        }
    }
    
    func processUIBlockConfigData(moduleUIdata: Data, result: @escaping ((_ isParsed: Bool) -> Void)) -> Void
    {
        let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()
        appSandBoxManager.updatePagesJSONFile(fileName: Constants.kBlocksFileName, fileData: moduleUIdata, platformJSONFileCallback: { (Bool) in
            result(true)
        })
    }
    
    
    func appConfigurationParsed() {
        finishedConfiguringApp(isAppConfigured: true)
    }
    
    
    func checkVersionOfFileFromDownloadedContent(downloadedContentData: Data, currentSavedFilePath: String) -> Bool
    {
        var isVersionChanged: Bool = false
        let downloadedFileVersion: String = AppParser.retrunVersionOfJsonFile(fileData: downloadedContentData)
        let fileCurrentData: Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: currentSavedFilePath)
        if fileCurrentData != nil
        {
            let currentFileVersion: String = AppParser.retrunVersionOfJsonFile(fileData: fileCurrentData!)

            if downloadedFileVersion != currentFileVersion { //|| checkIfAppVersionChanged() {
                isVersionChanged = true
            }
            else
            {
                isVersionChanged = false
            }
            return isVersionChanged
        }
        else
        {
            return true
        }
        
    }
    
    func checkIfAppVersionChanged() -> Bool {
        
        var isAppVersionChanged = false
        
        guard let currentVersionReleaseDate = Utility.sharedUtility.getCurrentAppVersionDateFromiTunes() else { return false }
        
        let appVerionReleaseDate = Constants.kSTANDARDUSERDEFAULTS.value(forKey: "AppVersionReleaseDate") as? String
        
        if appVerionReleaseDate != nil {
            
            if appVerionReleaseDate != currentVersionReleaseDate {
                
                isAppVersionChanged = true
            }
        }
        else {
            
            isAppVersionChanged = true
        }
                
        return isAppVersionChanged
    }
    
    
    func configureAppFromPreFetchedFiles() -> Void {
        let appConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!)
        if let appDictionary = appConfigJson as? [String: Any] {
            let appParser = AppParser()
            appParser.appParserDelegate = self
            appParser.parseAppMainConfigurationJson(appConfigDictionary: appDictionary as Dictionary<String, AnyObject>, methodCallback: { (iOSJsonUrl: String?) in
                
                if FileManager.default.fileExists(atPath: AppSandboxManager.getPlatformJSONFilePath()) {
                    //guard is used as  app was crashing in case of search file is not available due to any reason at destination path.
                    guard let iOSFileData: Data = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath()) else { return }
                    //let iOSFileData: Data = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!
                    
                    if (iOSFileData.count) > 0
                    {
                        let iOSConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!)
                        
                        if let iOSDictionary = iOSConfigJson as? [String: Any] {
                            let appParser = AppParser()
                            appParser.appParserDelegate = self
                            appParser.parseiOSConfigurationJson(iOSConfigDictionary: iOSDictionary as Dictionary<String, AnyObject>,
                                                                iOSConfigJsonCallback:
                                { (Array) in
                                    
                                    if AppConfiguration.sharedAppConfiguration.modulesUIBlock != nil
                                    {
                                        if AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl != nil && FileManager.default.fileExists(atPath: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))
                                        {
                                            let blockJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))!)
                                            if let blockDict = blockJson as? [String: Any]
                                            {
                                                PageUIBlocks.sharedInstance.parseBlockComponents(blockDict: blockDict)
                                            }
                                        }
                                        else
                                        {
                                            self.updateFilesInApplicationFolder()
                                            return
                                        }
                                    }
                                    self.pageCount = Array.count
                                    if self.pageCount == 0
                                    {
                                        self.updateFilesInApplicationFolder()
                                    }
                                    else {
                                        self.currentCount = 0

                                        for var pageDictionary in Array as! [Dictionary<String, AnyObject>]
                                        {
                                            let pageData: Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: pageDictionary["Page-ID"] as! String))
                                            
                                            if pageData != nil {
                                                
                                                if (pageData?.count)! > 0
                                                {
                                                    self.processPageConfigData(pageConfigdata: pageData!, jsonPageName: pageDictionary["Page-ID"] as! String, result: { (Bool) in
                                                        if self.currentCount + 1 == self.pageCount
                                                        {
                                                            self.finishedConfiguringApp(isAppConfigured: true)
                                                            DispatchQueue.global(qos: .background).async {
                                                                self.downloadConfigFilesInBackground()
                                                            }
                                                        }
                                                    })
                                                    self.currentCount = self.currentCount + 1
                                                }
                                            }
                                            else
                                            {
                                                self.updateFilesInApplicationFolder()
                                                break
                                            }
                                        }
                                    }
                                    
                            },
                                                                iOSConfigPlistCallback:
                                { (Dictionary) in
                                    
                            }
                            )
                        }
                    }
                }
                else {
                    self.updateFilesInApplicationFolder()
                }
            })
        }
    }
    
    func downloadConfigFilesInBackground() -> Void {
        let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
        
        let siteId:String = dicRoot["SiteId"] as! String
        let uiJsonBaseUrl:String = dicRoot["UIJsonBaseUrl"] as! String
        
        var apiEndPoint:String = "\(uiJsonBaseUrl)/\(siteId)/main.json?x="
        
        let currentTime = Date().timeIntervalSince1970
        apiEndPoint.append(String(describing: currentTime))
        
        self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
            
            if downloadedJSONData != nil && isSuccess{
                
                if (downloadedJSONData?.count)! > 0
                {
                    let appSandBoxManager: AppSandboxManager = AppSandboxManager.init()
                    
                    if self.checkVersionOfFileFromDownloadedContent(downloadedContentData: downloadedJSONData!, currentSavedFilePath: AppSandboxManager.getMainFilePath()) {
                        Constants.kAPPDELEGATE.isVersionChanged = true
                        
                        appSandBoxManager.updateMainFile(fileData: downloadedJSONData!) { (Bool) in

                            let appConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getMainFilePath())!)
                            if let appDictionary = appConfigJson as? [String: Any] {
                                let appParser = AppParser()
                                appParser.appParserDelegate = self
                                appParser.parseAppMainConfigurationJson(appConfigDictionary: appDictionary as Dictionary<String, AnyObject>, methodCallback: { (iOSJsonUrl: String?) in
                                    
                                    if iOSJsonUrl != nil {
                                        apiEndPoint = "\(iOSJsonUrl!)?x="
                                        
                                        if AppConfiguration.sharedAppConfiguration.configFileTimestamp != nil {
                                            
                                            apiEndPoint.append(String(describing: AppConfiguration.sharedAppConfiguration.configFileTimestamp!))
                                        }
                                        
                                        if FileManager.default.fileExists(atPath: AppSandboxManager.getPlatformJSONFilePath())
                                        {
                                            let platformJSONDownloadedVersion: String = AppParser.retrunVersionOfJsonFile(fileData: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!)
                                            let iOSStringURL: URL = URL.init(string: iOSJsonUrl ?? "")!
                                            let updatedPlatformVersion: String = iOSStringURL.valueOf(queryParamaterName: "version") ?? ""
                                            if updatedPlatformVersion != ""
                                            {
                                                if self.checkIfVersionOfFileIsChanged(networkFileVersion: updatedPlatformVersion, localFileVersion: platformJSONDownloadedVersion)
                                                {
                                                    self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                                                        
                                                        AppConfiguration.sharedAppConfiguration.createAppConfigurationPlist()
                                                        
                                                        if downloadedJSONData != nil
                                                        {
                                                            if (downloadedJSONData?.count)! > 0
                                                            {
                                                                appSandBoxManager.updatePlatformJSONFile(fileData: downloadedJSONData!) { (Bool) in
                                                                    let iOSConfigJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getPlatformJSONFilePath())!)
                                                                    
                                                                    if let iOSDictionary = iOSConfigJson as? [String: Any] {
                                                                        let appParser = AppParser()
                                                                        appParser.appParserDelegate = self
                                                                        appParser.parseiOSConfigurationJson(iOSConfigDictionary: iOSDictionary as Dictionary<String, AnyObject>,
                                                                                                            iOSConfigJsonCallback:
                                                                            { (Array) in
                                                                                
                                                                                if AppConfiguration.sharedAppConfiguration.modulesUIBlock != nil
                                                                                {
                                                                                    if AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl != nil
                                                                                    {
                                                                                        if FileManager.default.fileExists(atPath: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))
                                                                                        {
                                                                                            if self.checkIfVersionOfFileIsChanged(networkFileVersion: AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIVersion ?? "0", localFileVersion: AppParser.retrunVersionOfJsonFile(fileData: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))!))
                                                                                            {
                                                                                                var moduleUIURL: String = (AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl)!
                                                                                                
                                                                                                moduleUIURL.append("?version=\(AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIVersion ?? "0")")
                                                                                                
                                                                                                NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: moduleUIURL) { (jsonData, isSuccess) in
                                                                                                    
                                                                                                    if jsonData != nil && isSuccess
                                                                                                    {
                                                                                                        self.processUIBlockConfigData(moduleUIdata: jsonData!, result: { (success) in
                                                                                                            let blockJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))!)
                                                                                                            if let blockDict = blockJson as? [String: Any]
                                                                                                            {
                                                                                                                PageUIBlocks.sharedInstance.parseBlockComponents(blockDict: blockDict)
                                                                                                            }
                                                                                                        })
                                                                                                        
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            var moduleUIURL: String = (AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIUrl)!
                                                                                            
                                                                                            moduleUIURL.append("?version=\(AppConfiguration.sharedAppConfiguration.modulesUIBlock?.moduleUIVersion ?? "0")")
                                                                                            
                                                                                            NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: moduleUIURL) { (jsonData, isSuccess) in
                                                                                                
                                                                                                if jsonData != nil && isSuccess
                                                                                                {
                                                                                                    self.processUIBlockConfigData(moduleUIdata: jsonData!, result: { (success) in
                                                                                                        let blockJson = try? JSONSerialization.jsonObject(with: AppSandboxManager.getContentOfFilesAt(fileLocation: AppSandboxManager.getpageFilePath(fileName: Constants.kBlocksFileName))!)
                                                                                                        if let blockDict = blockJson as? [String: Any]
                                                                                                        {
                                                                                                            PageUIBlocks.sharedInstance.parseBlockComponents(blockDict: blockDict)
                                                                                                        }
                                                                                                    })
                                                                                                    
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                                
                                                                                if Array.isEmpty == false {
                                                                                    
                                                                                    var toBeUpdatedFiles: Array<Any> = []
                                                                                    
                                                                                    var ii: Int = 0
                                                                                    for var pageDictionary in Array as! [Dictionary<String, AnyObject>]
                                                                                    {
                                                                                        apiEndPoint = "\(pageDictionary["Page-UI"] as! String)"
                                                                                        let localFilePath: String = AppSandboxManager.getpageFilePath(fileName: pageDictionary["Page-ID"] as! String)
                                                                                        if FileManager.default.fileExists(atPath: localFilePath)
                                                                                        {
                                                                                            let localFileVersion: String = AppParser.retrunVersionOfJsonFile(fileData: AppSandboxManager.getContentOfFilesAt(fileLocation: localFilePath)!)

                                                                                            if self.checkIfVersionOfFileIsChanged(networkFileVersion: pageDictionary["version"] as! String, localFileVersion: localFileVersion)
                                                                                            {
                                                                                                toBeUpdatedFiles.append(pageDictionary)
                                                                                            }
                                                                                        }
                                                                                        if Array.count  == ii
                                                                                        {
                                                                                            break
                                                                                        }
                                                                                        ii = ii + 1
                                                                                    }
                                                                                    
                                                                                    self.pageCount = toBeUpdatedFiles.count
                                                                                    self.currentCount = 0
                                                                                    
                                                                                    if toBeUpdatedFiles.count == 0
                                                                                    {
                                                                                        #if os(iOS)
                                                                                        Constants.kAPPDELEGATE.shouldDisplayAppUpdateView = true
                                                                                        #endif
                                                                                            NotificationCenter.default.post(name: Notification.Name(Constants.kAppConfigureNotification), object: nil)
                                                                                    }
                                                                                    for var pageDictionary in toBeUpdatedFiles as! [Dictionary<String, AnyObject>]
                                                                                    {
                                                                                        apiEndPoint = "\(pageDictionary["Page-UI"] as! String)"
                                                                                        let localFilePath: String = AppSandboxManager.getpageFilePath(fileName: pageDictionary["Page-ID"] as! String)
                                                                                        if FileManager.default.fileExists(atPath: localFilePath)
                                                                                        {
                                                                                            var zz: Int = 0
                                                                                            for page in AppConfiguration.sharedAppConfiguration.pages
                                                                                            {
                                                                                                let localPage: Page = page
                                                                                                if localPage.pageId == (pageDictionary["Page-ID"] as! String)
                                                                                                {
                                                                                                    localPage.isPageUpdated = true
                                                                                                    AppConfiguration.sharedAppConfiguration.pages[zz] = localPage
                                                                                                }
                                                                                                zz = zz + 1
                                                                                            }
                                                                                            
                                                                                            self.downloadConfigurationFile (apiURL: apiEndPoint) { (downloadedJSONData, isSuccess) in
                                                                                                
                                                                                                if downloadedJSONData != nil {
                                                                                                    
                                                                                                    if (downloadedJSONData?.count)! > 0
                                                                                                    {
                                                                                                        appSandBoxManager.updatePagesJSONFile(fileName: pageDictionary["Page-ID"] as! String, fileData: downloadedJSONData!, platformJSONFileCallback: { (Bool) in
                                                                                                            
                                                                                                        })
                                                                                                    }
                                                                                                }
                                                                                                else //If Data coming as nil
                                                                                                {
                                                                                                    
                                                                                                }
                                                                                                
                                                                                                self.currentCount = self.currentCount + 1
                                                                                                if self.currentCount == self.pageCount
                                                                                                {
                                                                                                    #if os(iOS)
                                                                                                        Constants.kAPPDELEGATE.shouldDisplayAppUpdateView = true
                                                                                                    #endif
                                                                                                    NotificationCenter.default.post(name: Notification.Name(Constants.kUpdateAppNotification), object: nil)
                                                                                                    NotificationCenter.default.post(name: Notification.Name(Constants.kAppConfigureNotification), object: nil)
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                                else
                                                                                {
                                                                                    
                                                                                }
                                                                        },
                                                                                                            iOSConfigPlistCallback:
                                                                            { (Dictionary) in
                                                                                let plistData = NSDictionary(dictionary: Dictionary)
                                                                                AppSandboxManager.updatePlatformPlist(platformPlistDictionary: plistData)
                                                                        }
                                                                        )
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        else //If Data coming as nil
                                                        {
                                                            
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    AppConfiguration.sharedAppConfiguration.createAppConfigurationPlist()
                                                    #if os(iOS)
                                                        Constants.kAPPDELEGATE.shouldDisplayAppUpdateView = true
                                                    #endif
                                                    NotificationCenter.default.post(name: Notification.Name(Constants.kAppConfigureNotification), object: nil)
                                                }
                                            }
                                        }
                                        else
                                        {
                                            self.updateFilesInApplicationFolder()
                                        }
                                    }
                                    else {
                                        //Need to handle this
                                    }
                                })
                            }
                        }
                    }
                    else // No change in main configuration file version
                    {
                        
                    }
                }
            }
            else //If Data coming as nil
            {
                
            }
        }
    }
    
    
    func checkIfVersionOfFileIsChanged(networkFileVersion: String, localFileVersion: String) -> Bool {
        var isFileVersionChanged = false
        
        if (networkFileVersion != localFileVersion){
            isFileVersionChanged = true
        }
        
        return isFileVersionChanged
    }
    
}
