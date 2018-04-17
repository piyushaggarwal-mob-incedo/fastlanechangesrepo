//
//  AppSandboxManager.swift
//  AppCMS
//  This class manages saving App CMS json files, manages json file, folder structure
//  Created by Abhinav Saldi on 23/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class AppSandboxManager: NSObject
{
    //MARK: Class Methods
    class func getDocumentDirectoryPath() -> String
    {
        let documentDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentDirectoryPath
    }
    
    //MARK: getDirectoryPathForTargeted_Device either return's document directory path or Cashe directory path depending on app run's on tvos or ios
    class func getDirectoryPathForTargeted_Device() -> String
    {
        var  directoryPath : String
        
        #if os(tvOS)
            directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        #elseif os(iOS)
            directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        #endif

//        print("DirectoryPath: \(directoryPath)")
        return directoryPath
    }
    
    class func getMainFilePath() -> String
    {
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/Main.json"

        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else
        {
            return ""
        }
    }
    
    class func getPlatformJSONFilePath() -> String
    {
        var fileName = "iOS"
        #if os(tvOS)
            fileName = "AppleTV"
        #endif
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/\(fileName).json"
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else
        {
            return ""
        }
    }
    
    class func getpageFilePath(fileName: String) -> String
    {
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Pages/" + fileName + ".json"

        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else
        {
            return ""
        }
    }
    
    class func readGeneralPlistFile() -> String
    {
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/General.plist"

        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else
        {
            return ""
        }
    }
    
    class func readPlatformPlistFile() -> String
    {
        var fileName = "iOS"
        #if os(tvOS)
            fileName = "AppleTV"
        #endif
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/\(fileName).plist"

        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        else {
            return ""
        }
    }
    
    class func updateGeneralPlist(generalPlistDictionary:NSDictionary) -> Void {
        
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/General.plist"

        let plistDict = NSDictionary(dictionary: generalPlistDictionary)
        plistDict.write(toFile: filePath, atomically: true)
    }
    
    class func updatePlatformPlist(platformPlistDictionary:NSDictionary) -> Void {
        
        var fileName = "iOS"
        #if os(tvOS)
            fileName = "AppleTV"
        #endif
        let filePath: String = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/\(fileName).plist"

        let plistDict = NSDictionary(dictionary: platformPlistDictionary)
        plistDict.write(toFile: filePath, atomically: true)
    }
    
    class func getContentOfFilesAt(fileLocation: String) -> Data?
    {
        if fileLocation == ""
        {
            return nil
        }
        else
        {
            var fileData: Data
            fileData = FileManager.default.contents(atPath: fileLocation)!
            return fileData

        }
    }
    
    
    //MARK: manage folders
    func manageAppDocumentDirectoryStructure(methodCallback: @escaping ((_ appStructureMaseSuccessfully: Bool) -> Void)) -> Void
    {
        if (AppSandboxManager.getDocumentDirectoryPath().characters.count > 0)
        {
            let pathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure"

            if FileManager.default.fileExists(atPath: pathString)
            {
                createAppFolderStructure(pathString: pathString, folderCreatorCallBack: { (Bool) in
                    methodCallback(true)
                })
            }
            else
            {
                weak var weakSelf: AppSandboxManager? = self
                createFolder(path: pathString, folderCallback: { (Bool) in
                    weakSelf?.createAppFolderStructure(pathString: pathString, folderCreatorCallBack: { (Bool) in
                        methodCallback(true)
                    })
                })
            }
        }
    }
    
    func createAppFolderStructure(pathString: String, folderCreatorCallBack: @escaping ((_ folderCreated: Bool) -> Void)) -> Void {
        var ii = 0
        createMainFolder(basePath: pathString, mainFolderCallback: { (String) in
            ii = ii + 1
            if ii == 3
            {
                folderCreatorCallBack(true)
            }
        })
        createPagesFolder(basePath: pathString) { (String) in
            ii = ii + 1
            if ii == 3
            {
                folderCreatorCallBack(true)
            }
        }
        createNavigationPages(basePath: pathString) { (String) in
            ii = ii + 1
            if ii == 3
            {
                folderCreatorCallBack(true)
            }
        }
    }
    
    func createMainFolder(basePath: String, mainFolderCallback: @escaping ((_ createdMainFolder: String) -> Void)) -> Void {
        let folderPath = basePath + "/Main"
        if FileManager.default.fileExists(atPath: folderPath)
        {
           mainFolderCallback(folderPath)
        }
        else
        {
            createFolder(path: folderPath, folderCallback: { (Bool) in
                mainFolderCallback(folderPath)
            })
        }
    }
    
    
    func createPagesFolder(basePath: String, mainFolderCallback: @escaping ((_ createdMainFolder: String) -> Void)) -> Void {
        let folderPath = basePath + "/Pages"
        if FileManager.default.fileExists(atPath: folderPath)
        {
            mainFolderCallback(folderPath)
        }
        else
        {
            createFolder(path: folderPath, folderCallback: { (Bool) in
                mainFolderCallback(folderPath)
            })
        }
    }
    
    func createNavigationPages(basePath: String, mainFolderCallback: @escaping ((_ createdMainFolder: String) -> Void)) -> Void {
        let folderPath = basePath + "/NavPages"
        if FileManager.default.fileExists(atPath: folderPath)
        {
            mainFolderCallback(folderPath)
        }
        else
        {
            createFolder(path: folderPath, folderCallback: { (Bool) in
                mainFolderCallback(folderPath)
            })
        }
    }
    
    
    //MARK: Files Manager
    func updateGeneralPlistFile(fileData: Data, generalFileCallback: @escaping ((_ isFileUpdated: Bool) -> Void)) -> Void
    {
        let filePathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/General.plist"

        if FileManager.default.fileExists(atPath: filePathString)
        {
            updateFile(path: filePathString, data: fileData, fileCallback: { (Bool) in
                generalFileCallback(true)
            })
        }
        else
        {
            createFile(path: filePathString, fileData: fileData, fileCallback: { (Bool) in
                generalFileCallback(true)
            })
        }
    }
    
    func updatePlatformPlistFile(fileData: Data, generalFileCallback: @escaping ((_ isFileUpdated: Bool) -> Void)) -> Void
    {
        var fileName = "iOS"
        #if os(tvOS)
            fileName = "AppleTV"
        #endif
        let filePathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/\(fileName).plist"

        if FileManager.default.fileExists(atPath: filePathString)
        {
            updateFile(path: filePathString, data: fileData, fileCallback: { (Bool) in
                generalFileCallback(true)
            })
        }
        else
        {
            createFile(path: filePathString, fileData: fileData, fileCallback: { (Bool) in
                generalFileCallback(true)
            })
        }
    }
    
    func updateMainFile(fileData: Data, mainFileCallback: @escaping ((_ isFileUpdated: Bool) -> Void)) -> Void
    {

        let filePathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/Main.json"

        if FileManager.default.fileExists(atPath: filePathString)
        {
            updateFile(path: filePathString, data: fileData, fileCallback: { (Bool) in
                mainFileCallback(true)
            })
        }
        else
        {
            createFile(path: filePathString, fileData: fileData, fileCallback: { (Bool) in
                mainFileCallback(true)
            })
        }
    }
    
    func updatePlatformJSONFile(fileData: Data, platformJSONFileCallback: @escaping ((_ isFileUpdated: Bool) -> Void)) -> Void
    {
        var fileName = "iOS"
        #if os(tvOS)
            fileName = "AppleTV"
        #endif
        let filePathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Main/\(fileName).json"

        if FileManager.default.fileExists(atPath: filePathString)
        {
            updateFile(path: filePathString, data: fileData, fileCallback: { (Bool) in
                platformJSONFileCallback(true)
            })
        }
        else
        {
            createFile(path: filePathString, fileData: fileData, fileCallback: { (Bool) in
                platformJSONFileCallback(true)
            })
        }
    }
    
    
    func updatePagesJSONFile(fileName: String, fileData: Data, platformJSONFileCallback: @escaping ((_ isFileUpdated: Bool) -> Void)) -> Void
    {
        
        let filePathString = AppSandboxManager.getDirectoryPathForTargeted_Device() + "/AppStructure/Pages/" + fileName + ".json"

        if FileManager.default.fileExists(atPath: filePathString)
        {
            updateFile(path: filePathString, data: fileData, fileCallback: { (Bool) in
                platformJSONFileCallback(true)
            })
        }
        else
        {
            createFile(path: filePathString, fileData: fileData, fileCallback: { (Bool) in
                platformJSONFileCallback(true)
            })
        }
    }
    
    
    func updatePagesFilesInSandboxFolder(pagesCallBack: @escaping((_ filesUpdated: Bool)->Void)) -> Void
    {
        
    }
    
    func updateNavigationPages() -> Void
    {
        
    }
    
    
    //MARK: Folder Management Methods
    private
    func createFolder(path: String, folderCallback: @escaping ((_ folderCreated: Bool) -> Void)) -> Void
    {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            if FileManager.default.fileExists(atPath: path)
            {
                folderCallback(true)
            }
            else
            {
                folderCallback(false)
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
            folderCallback(false)
        }
    }
    
    private
    func createFile(path: String, fileData: Data, fileCallback: @escaping ((_ fileCreated: Bool) -> Void)) -> Void
    {
        let fileCreated: Bool = FileManager.default.createFile(atPath: path, contents: fileData, attributes: nil)
        fileCallback(fileCreated)
    }
    
    private
    func updateFile(path: String, data: Data, fileCallback: @escaping ((_ fileCreated: Bool) -> Void)) -> Void
    {
        do
        {
            try FileManager.default.removeItem(atPath: path)
            if !FileManager.default.fileExists(atPath: path) {
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            }
            else
            {
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            }
            fileCallback(true)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
            fileCallback(false)
        }
    }
}
