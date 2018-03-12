//
//  DownloadStorageManager.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class DownloadStorageManager: NSObject {

    func generateFilePath(forFileName fileName: String, withType type: String) -> String {
        var fileFolderPath: String
        if checkIfFileExist(inDownloads: fileName, andType: type) != "" {
            let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            fileFolderPath = URL(fileURLWithPath: documentsPath!).appendingPathComponent(fileName).absoluteString
        }
        else {
            fileFolderPath = self.createFolder(withFileName: fileName)
        }
        return fileFolderPath
    }

    func checkIfFileExist(inDownloads fileName: String, andType type: String) -> String {
        var isFileExist: Bool = false
        var filePath: String
        if checkIfFolderExist(withFileName: fileName) {
            let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            var userID = ""
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
                userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)) as! String
            }
            let folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)/\(fileName)").absoluteString
            let Path = URL(fileURLWithPath: folderPath).appendingPathComponent("\(fileName).\(type)")
            isFileExist = FileManager.default.fileExists(atPath: Path.path)
            if !isFileExist {
                filePath = ""
            }
            else{
                filePath = Path.path
            }
        }
        else {
            filePath = ""
        }
        return filePath
    }

    func checkIfFolderExist(withFileName fileName: String) -> Bool {
        let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var userID = ""
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)) as! String
        }
        let folderPath = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)/\(fileName)")
        return FileManager.default.fileExists(atPath: folderPath.path)
    }


    func createFolder(withFileName fileName:String) -> String {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let logsPath = documentsPath.appendingPathComponent("Downloads")
        if !FileManager.default.fileExists(atPath: logsPath!.path) {
            do {
                try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        var userID = ""
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)) as! String
        }
        let userFolderPath = logsPath?.appendingPathComponent(userID)
        if !FileManager.default.fileExists(atPath: userFolderPath!.path) {
            do {
                try FileManager.default.createDirectory(atPath: userFolderPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        let fileFolderPath = userFolderPath?.appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: fileFolderPath!.path) {
            do {
                try FileManager.default.createDirectory(atPath: fileFolderPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }

        return (fileFolderPath?.absoluteString)!
    }

    func updatePlistFileContent(forFileName fileName: String, andObject thisObject: DownloadObject) {

        // DispatchQueue.global(qos: .utility).async {
        var data = Dictionary<AnyHashable, Any>()
        var filePath: String = self.checkIfFileExist(inDownloads: fileName, andType: "plist")
        let filePathLength = Int(filePath.count)
        if  filePathLength == 0 {
            filePath = self.createFolder(withFileName: fileName) + "\(fileName).plist"
        }
        data["fileID"] = thisObject.fileID
        data["filePriority"] = "\(thisObject.filePriority)"
        data["fileName"] = thisObject.fileName
        data["fileCourseID"] = thisObject.fileCourseID
        data["fileCourseName"] = thisObject.fileCourseName
        data["fileUrl"] = thisObject.fileUrl
        data["fileImageUrl"] = thisObject.fileImageUrl
        data["filePosterImageUrl"] = thisObject.filePosterImageUrl
        data["fileDurationMinutes"] = thisObject.fileDurationMinutes
        data["fileDurationSeconds"] = thisObject.fileDurationSeconds
        data["fileDescription"] = thisObject.fileDescription
        data["fileCurrentDownloadedLength"] = "\(thisObject.fileCurrentDownloadedLength)"
        data["fileTotalLength"] = "\(thisObject.fileTotalLength)"
        data["filePathUrl"] = thisObject.filePathUrl
        
        if !thisObject.fileWatchedPercentage.isNaN && !thisObject.fileWatchedPercentage.isInfinite {
            
            data["fileWatchedPercentage"] = Int(thisObject.fileWatchedPercentage)
        }
        // data["fileModifiedDateTime"] = thisObject.fileModifiedDateTime
        data["fileNumber"] = "\(thisObject.fileNumber)"
        data["fileBitRate"] = "\(thisObject.fileBitRate)"
        if let parentalRating = thisObject.parentalRating{
            data["parentalRating"] = "\(parentalRating)"
        }
        if let year = thisObject.year{
            data["year"] = "\(year)"
        }
        if let primaryCategory = thisObject.primaryCategory{
            data["primaryCategory"] = "\(primaryCategory)"
        }
        if thisObject.viewerGrade != nil {
            data["viewerGrade"] = "\(thisObject.viewerGrade!)"
        }
            switch thisObject.fileDownloadState! {
            case .eDownloadStateInProgress:
                data["fileDownloadState"] = "0"
            case .eDownloadStateFinished:
                data["fileDownloadState"] = "1"
            case .eDownloadStateError:
                data["fileDownloadState"] = "2"
            case .eDownloadStateQueued:
                data["fileDownloadState"] = "3"
            case .eDownloadStatePaused:
                data["fileDownloadState"] = "4"
            case .eDownloadStateForcePaused:
                 data["fileDownloadState"] = "5"
            default:
                break
            }
            filePath = filePath.replacingOccurrences(of: "file://", with: "")
            
            let succeed = (data as NSDictionary).write(toFile: filePath, atomically: true)
    }
  
    func removeFile(_ fileName: String, withSuccess success: @escaping (_: Void) -> Void, andFailure failure: @escaping (_: Error) -> Void) {
        if checkIfFolderExist(withFileName: fileName) {
            let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            var userID = ""
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
                userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)) as! String
            }
            var folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)/\(fileName)").absoluteString
            folderPath = folderPath.replacingOccurrences(of: "file://", with: "")
            let error: Error? = nil
            try? FileManager.default.removeItem(atPath: folderPath)
            if  (error != nil) {
                failure(error!)
            }
            else {
                success()
            }
        }
    }

    func removeAllFiles(withSuccess success: @escaping (_: Void) -> Void, andFailure failure: @escaping (_: Void) -> Void) {
        let error: Error? = nil
        let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var userID = ""
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)) as! String
        }
        var folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)").absoluteString
        folderPath = folderPath.replacingOccurrences(of: "file://", with: "")
        try? FileManager.default.removeItem(atPath: folderPath)
        if  (error != nil) {
            failure()
        }
        else {
            success()
        }
    }

    func getDownloadObjects() -> [DownloadObject] {

        let documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var userID: String = ""
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            userID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as! String
        }
        var folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)").absoluteString
        var downloadObjectsArray = [Any]()
        var count: Int
        folderPath = folderPath.replacingOccurrences(of: "file://", with: "")
        let directoryContent: [Any]? = try? FileManager.default.contentsOfDirectory(atPath: folderPath)
        if (directoryContent == nil) {
            return []
        }

        for count in 0..<Int((directoryContent?.count)!) {
            let directoryContentPath: String = (directoryContent?[count] as! String)
            var filePath: String = folderPath + ("/\(directoryContentPath)/\(directoryContentPath).plist")

            //convert the plist data to a Swift Dictionary
            let savedValue:Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: filePath) as? Dictionary <String, AnyObject>
            if savedValue == nil {
                continue;
            }
           // var savedValue = [AnyHashable: Any](contentsOfFile: filePath)
            var newDownloadObject = DownloadObject()
            newDownloadObject.fileID = savedValue?["fileID"] as! String
            newDownloadObject.filePriority =  Int(savedValue?["filePriority"] as! String)!
            newDownloadObject.fileName = savedValue?["fileName"] as! String
            newDownloadObject.fileUrl = savedValue?["fileUrl"] as! String
            newDownloadObject.fileImageUrl = savedValue?["fileImageUrl"] as! String
            newDownloadObject.filePosterImageUrl = savedValue?["filePosterImageUrl"] as? String ?? ""
            newDownloadObject.fileBitRate = savedValue?["fileBitRate"] as? String ?? ""
            newDownloadObject.fileDurationMinutes = savedValue?["fileDurationMinutes"] as? NSNumber
            newDownloadObject.fileDescription = savedValue?["fileDescription"] as! String
            newDownloadObject.fileDurationSeconds = savedValue?["fileDurationSeconds"] as? NSNumber
            newDownloadObject.fileCurrentDownloadedLength = Double(savedValue?["fileCurrentDownloadedLength"] as! String)!
            newDownloadObject.fileTotalLength = Double(savedValue?["fileTotalLength"] as! String)!
            newDownloadObject.filePathUrl = savedValue?["filePathUrl"] as! String
            newDownloadObject.fileWatchedPercentage = savedValue?["fileWatchedPercentage"] as? Float ?? 0.0
            newDownloadObject.fileModifiedDateTime = savedValue?["fileModifiedDateTime"] as? Date
            if let parentalRating = savedValue?["parentalRating"] {
                newDownloadObject.parentalRating = parentalRating as? String
            }
            if let year = savedValue?["year"] {
                newDownloadObject.year = year as? String
            }
            if let primaryCategory = savedValue?["primaryCategory"] {
                newDownloadObject.primaryCategory = primaryCategory as? String
            }
            if savedValue?["viewerGrade"] != nil {
                newDownloadObject.viewerGrade = Double(savedValue?["viewerGrade"] as! String)!
            }
            switch Int(savedValue?["fileDownloadState"] as! String) ?? 0 {
            case 0:
                newDownloadObject.fileDownloadState = .eDownloadStateInProgress
            case 1:
                newDownloadObject.fileDownloadState = .eDownloadStateFinished
            case 2:
                newDownloadObject.fileDownloadState = .eDownloadStateError
            case 3:
                newDownloadObject.fileDownloadState = .eDownloadStateQueued
            case 4:
                newDownloadObject.fileDownloadState = .eDownloadStatePaused
            case 5:
                newDownloadObject.fileDownloadState = .eDownloadStateForcePaused
            default:
                newDownloadObject.fileDownloadState = .eDownloadStateNone
                break
            }

            //Check, if file content does not exist then delete the directory present on that location. Further handling done in Download Manager's calling method. Multilevel exception handling in place now. - AV
            if newDownloadObject.fileID == "" || newDownloadObject.filePathUrl == "" || newDownloadObject.fileUrl == "" || newDownloadObject.fileName == "" {
                if (directoryContentPath != "") && (directoryContentPath.count ) > 0 {
                    filePath = folderPath + ("\(String(describing: directoryContentPath))")
                    defer {
                    }
                    let error: Error? = nil
                    try? FileManager.default.removeItem(atPath: filePath)
                    if  (error != nil) {
                    }
                    else {
                    }

                }
            }
            else {
                //Else - Add to the returned array of objects.
                downloadObjectsArray.append(newDownloadObject)
            }
        }
        return downloadObjectsArray as! [DownloadObject]
    }

    func getMP4UrlPathForTheDownloadObject(forFileId fileId: String) -> String {
        var documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var userID: String = ""
        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil){
         userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String)!
        }
        let folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)/\(fileId)/\(fileId).mp4").absoluteString

        documentsPath = nil
        return folderPath.replacingOccurrences(of: "file://", with: "")
    }
    func getSubTitleFilePathForTheDownloadObject(forFileId fileId: String) -> String {
        var documentsPath: String? = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var userID: String = ""
        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil){
            userID = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String)!
        }
        let folderPath: String = URL(fileURLWithPath: documentsPath!).appendingPathComponent("Downloads/\(userID)/\(fileId)/\(fileId).srt").absoluteString
        
        documentsPath = nil
        return folderPath.replacingOccurrences(of: "file://", with: "")
    }


    func getFilePathForTheDownloadObject(forFileId fileId: String) -> String {
        return self.getMP4UrlPathForTheDownloadObject(forFileId: fileId);
    }
    
    func updateFile(_ fileName: String, watchedPercentage: Float) {
        if checkIfFolderExist(withFileName: fileName) {
            let filePath: String = checkIfFileExist(inDownloads: fileName, andType: "plist")
            let savedValue:Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: filePath) as? Dictionary <String, AnyObject>
            let newDownloadObject = DownloadObject()
            newDownloadObject.fileID = savedValue?["fileID"] as! String
            newDownloadObject.filePriority = Int(savedValue?["filePriority"] as! String)!
            newDownloadObject.fileName = savedValue?["fileName"] as! String
            newDownloadObject.fileUrl = savedValue?["fileUrl"] as! String
            newDownloadObject.fileImageUrl = savedValue?["fileImageUrl"] as! String
            newDownloadObject.filePosterImageUrl = savedValue?["filePosterImageUrl"] as! String
            newDownloadObject.fileBitRate = savedValue?["fileBitRate"] as? String ?? ""
            newDownloadObject.fileDurationMinutes = savedValue?["fileDurationMinutes"] as? NSNumber
            newDownloadObject.fileDescription = savedValue?["fileDescription"] as! String
            newDownloadObject.fileDurationSeconds = savedValue?["fileDurationSeconds"] as? NSNumber
            newDownloadObject.fileCurrentDownloadedLength = Double(savedValue?["fileCurrentDownloadedLength"] as! String)!
            newDownloadObject.fileTotalLength = Double(savedValue?["fileTotalLength"] as! String)!
            newDownloadObject.filePathUrl = savedValue?["filePathUrl"] as! String
            newDownloadObject.fileWatchedPercentage = savedValue?["fileWatchedPercentage"] as! Float
            newDownloadObject.fileModifiedDateTime = savedValue?["fileModifiedDateTime"] as? Date
            newDownloadObject.fileNumber = Int(savedValue?["fileNumber"] as! String)!
            if let parentalRating = savedValue?["parentalRating"] {
                newDownloadObject.parentalRating = parentalRating as? String
            }
            if let year = savedValue?["year"] {
                newDownloadObject.year = year as? String
            }
            if let primaryCategory = savedValue?["primaryCategory"] {
                newDownloadObject.primaryCategory = primaryCategory as? String
            }
            if savedValue?["viewerGrade"] != nil {
                newDownloadObject.viewerGrade = Double(savedValue?["viewerGrade"] as! String)!
            }

            switch Int(savedValue?["fileDownloadState"] as! String)! {
            case 0:
                newDownloadObject.fileDownloadState = .eDownloadStateInProgress
                break
            case 1:
                newDownloadObject.fileDownloadState = .eDownloadStateFinished
                break
            case 2:
                newDownloadObject.fileDownloadState = .eDownloadStateError
                break
            case 3:
                newDownloadObject.fileDownloadState = .eDownloadStateQueued
                break
            case 4:
                newDownloadObject.fileDownloadState = .eDownloadStatePaused
                break
            case 5:
                newDownloadObject.fileDownloadState = .eDownloadStateForcePaused
            default:
                newDownloadObject.fileDownloadState = .eDownloadStateNone
                break
            }
            self.updatePlistFileContent(forFileName: fileName, andObject: newDownloadObject)
        }
    }
}
