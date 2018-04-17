//
//  DownloadManager.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
enum kDownloadQuality : Int {
    case downloadQualityHigh = 0
    case downloadQualityMedium = 1
    case downloadQualitylow = 2
}
extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
protocol globalDownloadManagerDelegate: NSObjectProtocol {
    /*!
     * @discussion delegate method to update current global download progress.
     * @param float progress - current download progress status in float
     * @return nil.
     */
    func updateGlobalDownloadProgress(withProgress progress: Float)

    /*!
     * @discussion delegate method to update an error occured to download progress.
     * @return nil.
     */
    func errorOccuredForDownload()

    /*!
     * @discussion delegate method to notify initial point of download.
     * @return nil.
     */
    func downloadStartForAnObject()
}
protocol downloadManagerDelegate: NSObjectProtocol {
    /*!
     * @discussion - Delegate method to update current global download progress.
     * @param DownloadObject* thisObject - This will hold the object for which Progress needs to be updated.
     * @param float progress - This will show current progress for global download. {Min 0.00, Max 1.00}.
     * @return nil.
     */
    func updateDownloadProgress(for thisObject: DownloadObject, withProgress progress: Float)

    /*!
     * @discussion - Delegate method to intimate download finished for an object.
     * @param DownloadObject* thisObject - This will hold the object for which Progress needs to be updated.
     * @return nil.
     */
    func downloadFinished(for thisObject: DownloadObject)

    /*!
     * @discussion - Delegate method to intimate download added to the downloading list.
     * @param DownloadObject* thisObject - This will hold the object for which state needs to be updated.
     * @return nil.
     */
    func downloadStateUpdate(for thisObject: DownloadObject)

    /*!
     * @discussion - Delegate method to intimate download failed with error.
     * @param DownloadObject* thisObject - This will hold the object for which state needs to be updated.
     * @return nil.
     */
    func downloadFailed(for thisObject: DownloadObject)
}

class DownloadManager: NSObject,TCBlobDownloaderDelegate {
    /*!
     *@ discussion - Property : Value of Current download quality checker.
     */
    //var downloadQuality = kDownloadQuality(rawValue: 0)!
    var downloadQuality:String = ""
    /*!
     *@ discussion - Property : This is an access for confirming to protocol globalDownloadDelegate.
     */
    weak var globalDownloadDelegate: globalDownloadManagerDelegate?
    /*!
     *@ discussion - Property : This is an access for confirming to protocol downloadManagerDelegate.
     */
    weak var downloadDelegate: downloadManagerDelegate?
    var currentDownloadingArray = [DownloadObject]()
    var downloadedArray = [DownloadObject]()
    var globalDownloadArray = [DownloadObject]()
    var currentSessionDownloadingArray = [DownloadObject]()
    var currentSessiondownloadedArray = [DownloadObject]()
    var storageManager = DownloadStorageManager()
    var downloadManager = TCBlobDownloadManager.sharedInstance()
    var currentDownload: TCBlobDownloader?
    var currentDownloadIndex = 0
    var totalDownloadLength = 0.0
    var currentPriority = 1
    var isDownloadingPaused = true
    var isThereIsDownloadInProgress = false

    static let sharedInstance:DownloadManager = {
        let instance = DownloadManager()
        NotificationCenter.default.addObserver(self, selector:#selector(memoryWarningReceived), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil);
        return instance
    }()

    func getDownloadedObjectsArray() -> [Any] {
        if self.downloadedArray.count > 0 {
            self.downloadedArray.removeAll()
        }
        if  currentDownloadingArray.count > 0 {
            currentDownloadingArray.removeAll()
        }
        if  currentSessiondownloadedArray.count > 0 {
            currentSessiondownloadedArray.removeAll()
        }
        if  currentSessionDownloadingArray.count > 0 {
            currentSessionDownloadingArray.removeAll()
        }
        if self.getGlobalDownloadObjectsArray().count == 0 {
            let downloadArray: [DownloadObject] = storageManager.getDownloadObjects()
            if downloadArray.count > 0 {
                for downloadObject: DownloadObject in downloadArray {
                    if downloadObject.fileID == "" || downloadObject.filePathUrl == "" || downloadObject.fileUrl == "" || downloadObject.fileName == "" {
                        //Don't add to the download objects.
                    }
                    else {
                        if downloadObject.fileDownloadState == .eDownloadStateInProgress || downloadObject.fileDownloadState == .eDownloadStateQueued || downloadObject.fileDownloadState == .eDownloadStatePaused || downloadObject.fileDownloadState == .eDownloadStateForcePaused {
                            //Additional check for progress where the state does not as finished for finished items.
                            if downloadObject.fileTotalLength > 0.0 && downloadObject.fileCurrentDownloadedLength == downloadObject.fileTotalLength {
                                downloadObject.fileDownloadState = .eDownloadStateFinished
                                updatePlist(forFile: downloadObject)
                            }
                            else {
                                if downloadObject.fileDownloadState == .eDownloadStateInProgress {
                                    downloadObject.fileDownloadState = .eDownloadStatePaused
                                    updatePlist(forFile: downloadObject)
                                }
                                currentDownloadingArray.append(downloadObject)
                                currentSessionDownloadingArray.append(downloadObject)
                            }
                        }
                        else {
                            self.downloadedArray.append(downloadObject)
                        }
                    }
                }
            }
            var sortDescriptor: NSSortDescriptor?
            sortDescriptor = NSSortDescriptor(key: "filePriority", ascending: true)
            self.currentDownloadingArray = (self.currentDownloadingArray as NSArray).sortedArray(using: [sortDescriptor!]) as! [DownloadObject]
            self.downloadedArray = (self.downloadedArray as NSArray).sortedArray(using: [sortDescriptor!]) as! [DownloadObject]
        }
        self.updateGlobalDownloadArray()
        return self.globalDownloadArray
    }

    func getDownloadProgress(forObject downloadObjectId: String) -> Float {
        var ii: Int = 0
        var progress: Float = 0.0
        for downloadingObject: DownloadObject in self.globalDownloadArray {
            if (downloadingObject.fileID == downloadObjectId) {
                progress = Float(downloadingObject.fileCurrentDownloadedLength / downloadingObject.fileTotalLength)
            }
            ii += 1
        }
        return progress
    }

    func addObject(toDownload thisObject: DownloadObject) {
        thisObject.filePathUrl = storageManager.generateFilePath(forFileName: thisObject.fileID, withType: "mp4")
        thisObject.fileModifiedDateTime = Date()
        thisObject.fileDownloadState = .eDownloadStateQueued
        thisObject.filePriority = currentPriority
        self.createPlistFile(with: thisObject, andFileName: thisObject.fileID)
        self.currentSessionDownloadingArray.append(thisObject)
        self.currentDownloadingArray.append(thisObject)
        self.updateGlobalDownloadArray()
        self.checkDownload()
        self.isThereIsDownloadInProgress = true
        self.globalDownloadDelegate?.downloadStartForAnObject()
        self.downloadDelegate?.downloadStateUpdate(for: thisObject)
        
        let userInfo:Dictionary<String, Any> = [Constants.kDownloadObject:thisObject]
        NotificationCenter.default.post(name: Notification.Name(Constants.kDownloadStatusUpdate), object: nil, userInfo: userInfo)
        /*
        GAI.sharedInstance().defaultTracker().send(GAIDictionaryBuilder.createEvent(withCategory: "Offline Viewing", action: "Download Started", label: thisObject.fileID, value: nil).build())
        */
    }

    func addAllObjects(toDownload downloadObjects: [DownloadObject]) {
        for toBeDownloadedObject: DownloadObject in downloadObjects {
            var present: Bool = false
            for addedObject: DownloadObject in globalDownloadArray {
                if (toBeDownloadedObject.fileID == addedObject.fileID) {
                    present = true
                }
            }
            if !present {
                self.addObject(toDownload: toBeDownloadedObject)
            }
        }
        isThereIsDownloadInProgress = true
        self.globalDownloadDelegate?.downloadStartForAnObject()
    }

    func checkDownload() {
        if (self.downloadManager?.currentDownloadsCount)! > 0 {
            return
        }
        else {
            if !isLecturesAtPauseState() {
                downloadNextObject(nextObject: nil)
            }
        }
    }

    func isLecturesAtPauseState() -> Bool {
        var isFound: Bool = false
        for downloadObject: DownloadObject in self.currentDownloadingArray {
            if downloadObject.fileDownloadState == .eDownloadStatePaused || downloadObject.fileDownloadState == .eDownloadStateForcePaused {
                isFound = true
                break
            }
        }
        return isFound
    }

    func downloadNextObject(nextObject: DownloadObject?) {
        if currentDownloadingArray.isEmpty {
            self.currentDownload = nil
            return
        }
        var downloadObject: DownloadObject?
        
        if (nextObject != nil) {
            downloadObject = nextObject
        }
        else{
            downloadObject = (currentDownloadingArray[0])
        }
        
        downloadObject?.fileDownloadState = .eDownloadStateInProgress
        self.currentDownload = nil
        var path = downloadObject?.filePathUrl
        path = path?.replacingOccurrences(of: "file://", with: "")
        self.currentDownload = TCBlobDownloader(url: URL(string: (downloadObject?.fileUrl)!), downloadPath: path, delegate: self)
        self.currentDownload?.qualityOfService = .utility
        currentDownload?.fileName = "\(downloadObject?.fileID ?? "").mp4"
        downloadManager?.startDownload(currentDownload)
        globalDownloadDelegate?.downloadStartForAnObject()
        if downloadObject != nil {
            self.downloadDelegate?.downloadStateUpdate(for: downloadObject!)
        }

    }

    func checkIfFolderExist(withFileName fileName: String) -> Bool {
        return self.storageManager.checkIfFolderExist(withFileName: fileName)
    }

    func createPlistFile(with thisObject: DownloadObject, andFileName fileName: String) {
         storageManager.updatePlistFileContent(forFileName: fileName, andObject: thisObject)
    }

    func removeObject(fromDownloadedArray fileID: String, withSuccessBlock success: @escaping (_: Void) -> Void, andFailureBlock failure: @escaping (_ error: Error?) -> Void) {
        if ("\(fileID).mp4" == currentDownload?.fileName) {
            self.currentDownload?.cancelDownloadAndRemoveFile(true)
        }
        weak var downloadTempObject: DownloadObject?
        for thisObject: DownloadObject in globalDownloadArray {
            if (thisObject.fileID == fileID) {
                downloadTempObject = thisObject
                break
            }
        }
        weak var weakSelf: DownloadManager? = self
        self.storageManager.removeFile(fileID, withSuccess: {() in
            if downloadTempObject?.fileDownloadState == .eDownloadStateFinished {
                var ii: Int = 0
                for currentObject: DownloadObject in (weakSelf?.downloadedArray)! {
                    if (currentObject.fileID == downloadTempObject?.fileID) {
                        weakSelf?.downloadedArray.remove(at: ii)
                        if (weakSelf?.currentSessiondownloadedArray.contains(downloadTempObject!))! {
                            weakSelf?.currentSessiondownloadedArray.remove(at: (weakSelf?.currentSessiondownloadedArray.index(of: downloadTempObject!)!)!)
                        }
                        if (weakSelf?.currentSessionDownloadingArray.contains(downloadTempObject!))! {
                            weakSelf?.currentSessionDownloadingArray.remove(at: (weakSelf?.currentSessionDownloadingArray.index(of: downloadTempObject!)!)!)
                        }
                        weakSelf?.updateGlobalDownloadArray()
                        break
                    }
                    ii += 1
                }
            }
            else{
                var ii: Int = 0
                for currentObject: DownloadObject in (weakSelf?.currentDownloadingArray)! {
                    if (currentObject.fileID == downloadTempObject?.fileID) {
                        let state: downloadObjectState = currentObject.fileDownloadState!
                        weakSelf?.currentDownloadingArray.remove(at: ii)
                        if (weakSelf?.currentSessiondownloadedArray.contains(downloadTempObject!))! {
                            weakSelf?.currentSessiondownloadedArray.remove(at: (weakSelf?.currentSessiondownloadedArray.index(of: downloadTempObject!)!)!)
                        }
                        if (weakSelf?.currentSessionDownloadingArray.contains(downloadTempObject!))! {
                            weakSelf?.currentSessionDownloadingArray.remove(at: (weakSelf?.currentSessionDownloadingArray.index(of: downloadTempObject!)!)!)
                        }
                        weakSelf?.updateGlobalDownloadArray()
                        if state == .eDownloadStateInProgress || state == .eDownloadStatePaused || state == .eDownloadStateForcePaused {
                            DispatchQueue.main.async(execute: {() -> Void in
                                weakSelf?.downloadNextObject(nextObject: nil)
                            })
                        }
                        if(state == .eDownloadStateQueued){
                            var dwonloadInprogress:Bool = false
                            for currentObject: DownloadObject in (weakSelf?.currentDownloadingArray)! {
                                if currentObject.fileDownloadState! == .eDownloadStateInProgress || currentObject.fileDownloadState! == .eDownloadStatePaused || currentObject.fileDownloadState! == .eDownloadStateForcePaused {
                                    dwonloadInprogress = true
                                    break;
                                }
                            }
                            if(!dwonloadInprogress){
                                DispatchQueue.main.async(execute: {() -> Void in
                                    weakSelf?.downloadNextObject(nextObject: nil)
                                })

                            }
                        }
                        break
                    }
                    ii += 1
                }
                if weakSelf?.currentDownloadingArray.count == 0 {
                    weakSelf?.isThereIsDownloadInProgress = false
                }
            }
            success()
            self.globalDownloadDelegate?.errorOccuredForDownload()
        }, andFailure: {(_ error: Error?) in
            self.isThereIsDownloadInProgress = true
            failure(error)
        })

    }

    func removeAllDownloadedContent(withSuccessBlock success: @escaping (_: Void) -> Void, andFailureBlock failure: @escaping (_: Void) -> Void) {
        self.currentDownload?.cancelDownloadAndRemoveFile(true)
        self.currentDownloadingArray.removeAll()
        self.downloadedArray.removeAll()
        self.currentSessiondownloadedArray.removeAll()
        self.currentSessionDownloadingArray.removeAll()
        self.updateGlobalDownloadArray()
        self.currentDownload = nil
        self.storageManager.removeAllFiles(withSuccess: success, andFailure: failure)
        self.isThereIsDownloadInProgress = false
        self.globalDownloadDelegate?.errorOccuredForDownload()
    }

    func removeTheCurrentDownloadAndFlushOutTheDataMaintainedLocallyForTheSession() {
        self.currentDownload?.cancelDownloadAndRemoveFile(false)
        self.currentDownloadingArray.removeAll()
        self.downloadedArray.removeAll()
        self.currentSessiondownloadedArray.removeAll()
        self.currentSessionDownloadingArray.removeAll()
        self.updateGlobalDownloadArray()
        self.currentDownload = nil
        self.isThereIsDownloadInProgress = false
        self.globalDownloadDelegate?.errorOccuredForDownload()
    }

    func stopAllDownloads() {
        self.downloadManager?.cancelAllDownloadsAndRemoveFiles(true)
    }
    /*
    func setDownloadQuality(_ downloadQuality: kDownloadQuality) {
        if self.downloadQuality != downloadQuality {
            self.downloadQuality = downloadQuality
            switch downloadQuality {
            case .downloadQualityHigh:
                Constants.kSTANDARDUSERDEFAULTS.set(0, forKey: Constants.kDownloadQualitySelectionkey)
                break;

            case .downloadQualityMedium:
                Constants.kSTANDARDUSERDEFAULTS.set(1, forKey: Constants.kDownloadQualitySelectionkey)
                break;

            case .downloadQualitylow:
                Constants.kSTANDARDUSERDEFAULTS.set(2, forKey: Constants.kDownloadQualitySelectionkey)
                break;
            }
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
        }
    }
    */

    func setDownloadQualityForDownload(_ downloadQuality: String) {
        if self.downloadQuality != downloadQuality {
            self.downloadQuality = downloadQuality
            Constants.kSTANDARDUSERDEFAULTS.set(downloadQuality, forKey: Constants.kDownloadQualitySelectionkey)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
        }
    }

    func stopDownload(with thisObject: DownloadObject) {
    }

    func updateGlobalDownloadProgress(withFinished finished: Bool) {
        var progress: Float
        if finished {
            progress = 1.0
            self.isThereIsDownloadInProgress = false
        }
        else {
            progress = calculateDownloadLengthOfDownload() / calculateTotalLengthOfDownload()
            self.isThereIsDownloadInProgress = true
        }
        self.globalDownloadDelegate?.updateGlobalDownloadProgress(withProgress: progress)

    }
    func calculateTotalLengthOfDownload() -> Float {
        var totalLength: Float = 0.0
        for downloadObject: DownloadObject in self.downloadedArray {
            totalLength = totalLength + Float(downloadObject.fileTotalLength)
        }
        for downloadingObject: DownloadObject in self.currentDownloadingArray {
            totalLength = totalLength + Float(downloadingObject.fileTotalLength)
        }
        return totalLength
    }

    func calculateDownloadLengthOfDownload() -> Float {
        var downloadingLength: Float = 0.0
        for downloadObject: DownloadObject in downloadedArray {
            downloadingLength = downloadingLength + Float(downloadObject.fileTotalLength)
        }
        let downloadingObject: DownloadObject? = (self.currentDownloadingArray[0])
        downloadingLength = downloadingLength + Float((downloadingObject?.fileCurrentDownloadedLength)!)
        return downloadingLength
    }

    func downloadingObjectsContainsFile(withID fileID: String) -> Bool {
        var presence: Bool = false
        for thisObject: DownloadObject in self.globalDownloadArray {
            if (thisObject.fileID == fileID) {
                presence = true
                break
            }
        }
        return presence
    }

    func changePriorityOfDownloadingObject(_ downloadingObject: DownloadObject, toPriority priority: Int) {
        var index: Int = 0

        var sortDescriptor: NSSortDescriptor?
        sortDescriptor = NSSortDescriptor(key: "filePriority", ascending: true)
        self.globalDownloadArray = (self.globalDownloadArray as NSArray).sortedArray(using: [sortDescriptor!]) as! [DownloadObject]

        for thisObject: DownloadObject in globalDownloadArray {
            if (thisObject.fileID == downloadingObject.fileID) {
                break
            }
            else {
                index += 1
            }
        }
        downloadingObject.filePriority = priority
        globalDownloadArray.remove(at: index)
        for tempObj: DownloadObject in self.globalDownloadArray {
            print("New 1 Priority = \(tempObj.filePriority), With File Name = \(tempObj.fileName)")
        }
        self.globalDownloadArray.insert(downloadingObject, at: priority)
        for tempObj: DownloadObject in self.globalDownloadArray {
            print("New 2 Priority = \(tempObj.filePriority), With File Name = \(tempObj.fileName)")
        }
        self.currentDownloadingArray.removeAll()
        self.downloadedArray.removeAll()
        for ii in 0..<self.globalDownloadArray.count {
            let thisObject: DownloadObject? = (self.globalDownloadArray[ii] )
            thisObject?.filePriority = ii + 1
            globalDownloadArray[ii] = thisObject!
            if thisObject?.fileDownloadState == .eDownloadStateFinished {
                downloadedArray.append(thisObject!)
            }
            else {
                currentDownloadingArray.append(thisObject!)
            }
            print("New Priority = \(String(describing: thisObject?.filePriority)), With File Name = \(String(describing: thisObject?.fileName))")
            storageManager.updatePlistFileContent(forFileName: (thisObject?.fileID)!, andObject: thisObject!)
        }
        self.updateGlobalDownloadArray()
    }

    func updateGlobalDownloadArray() {
        self.globalDownloadArray.removeAll()
        self.globalDownloadArray += self.downloadedArray
        self.globalDownloadArray += self.currentDownloadingArray
        self.currentPriority = Int(self.globalDownloadArray.count) + 1
        self.totalDownloadLength = 0.0
        for thisObject: DownloadObject in globalDownloadArray {
            self.totalDownloadLength = self.totalDownloadLength + thisObject.fileTotalLength
        }
        if self.globalDownloadArray.count > 0 {
            var sortDescriptor: NSSortDescriptor?
            sortDescriptor = NSSortDescriptor(key: "filePriority", ascending: true)
            self.globalDownloadArray = (self.globalDownloadArray as NSArray).sortedArray(using: [sortDescriptor!]) as! [DownloadObject]
        }
        var ii: Int = 1
        let tempGlobalDownloadedArray: [DownloadObject] = self.globalDownloadArray
        globalDownloadArray.removeAll()
        for downloadObject: DownloadObject in tempGlobalDownloadedArray {
            downloadObject.filePriority = ii
            globalDownloadArray.append(downloadObject)
            ii = ii + 1
            print("Priority : \(downloadObject.filePriority)")
        }
    }
    func getDownloadingObjectsArray() -> [DownloadObject] {
        return self.currentDownloadingArray
    }

    func getGlobalDownloadObjectsArray() -> [DownloadObject] {
        return self.globalDownloadArray
    }

    func getSavedObjectsArray() -> [DownloadObject] {
        return self.downloadedArray
    }

    func getCurrentSessionDownloadingObjectsArray() -> [DownloadObject] {
        return self.currentSessionDownloadingArray
    }

    func getCurrentSessionSavedObjectsArray() -> [DownloadObject] {
        return self.currentSessiondownloadedArray
    }

    func updatePlistForFile(objDownload:DownloadObject) -> Void {
        self.storageManager.updatePlistFileContent(forFileName: objDownload.fileID, andObject: objDownload)
    }

    func showMemoryWarningAlert() -> Void {
        var ii: Int = 0
        var index: Int = 0
        for thisObject: DownloadObject in self.currentDownloadingArray {
           if (self.currentDownload?.fileName == "\(thisObject.fileID).mp4") {
                index = (self.currentDownloadingArray as NSArray).index(of: thisObject)
                break
            }
            ii += 1
        }

        if currentDownloadingArray.count == 0 && index > currentDownloadingArray.count {
            return
        }
        if currentDownloadingArray.count > 0 {
            let downloadingObject: DownloadObject? = (currentDownloadingArray[index])
            let message:String = "\(downloadingObject?.fileName ?? "Movie") cannot be downloaded. There is not enough available space on your device."
            let cancelAction = UIAlertAction(title: Constants.kStrOk, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            })
            let alertController = UIAlertController(title: Constants.kMemoryCapacityErrorTiltle, message: message, preferredStyle: .alert)
            alertController.addAction(cancelAction)
            alertController.show()
        }
    }

    func memoryWarningReceived() {
        self.storageManager = DownloadStorageManager()
        self.pauseDownloadingObject(isForcePaused: true)
        self.showMemoryWarningAlert()

    }


    func pauseDownloadingObject(isForcePaused:Bool) {
        if (self.currentDownload != nil) {
            self.isDownloadingPaused = true
            self.currentDownload?.delegate = nil
            self.currentDownload?.cancelDownloadAndRemoveFile(false)
            var ii: Int = 0
            var index: Int = 0
            for thisObject: DownloadObject in currentDownloadingArray {
                if (self.currentDownload?.fileName == "\(thisObject.fileID).mp4") {
                    index = (currentDownloadingArray as NSArray).index(of: thisObject)
                    break
                }
                ii += 1
            }
            
            if currentDownloadingArray.count == 0 && index > currentDownloadingArray.count {
                return
            }
            
            if currentDownloadingArray.count > 0 {
                
                var downloadingObject: DownloadObject? = (currentDownloadingArray[index])
                
                if downloadingObject != nil {
                    
                    if downloadingObject?.fileDownloadState == .eDownloadStateInProgress {
                        if(isForcePaused){
                            downloadingObject?.fileDownloadState = .eDownloadStateForcePaused
                        }
                        else{
                            downloadingObject?.fileDownloadState = .eDownloadStatePaused
                        }
                        self.updatePlist(forFile: downloadingObject!)
                    }
                    self.downloadDelegate?.downloadStateUpdate(for: downloadingObject!)
                    
                    let userInfo:Dictionary<String, Any> = [Constants.kDownloadObject:downloadingObject!]
                    NotificationCenter.default.post(name: Notification.Name(Constants.kDownloadStatusUpdate), object: nil, userInfo: userInfo)
                    
                    downloadingObject = nil
                }
            }
            else {
                
                return
            }
        }
    }

    func resumeDownloadingObject(with thisObject: DownloadObject) {
        
        if (Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.RESUME_DOWNLOAD)) {
            return
        }
        
        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.RESUME_DOWNLOAD)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        var pausedDownload:DownloadObject? = thisObject
        
        for downloadObject: DownloadObject in self.currentDownloadingArray {
            if (downloadObject.fileDownloadState == .eDownloadStatePaused || downloadObject.fileDownloadState == .eDownloadStateForcePaused){
                pausedDownload = downloadObject
                break
            }
        }
        
        if (pausedDownload!.fileDownloadState == .eDownloadStateQueued){
            var dwonloadInprogress:Bool = false
            for currentObject: DownloadObject in (self.currentDownloadingArray){
                if currentObject.fileDownloadState! == .eDownloadStateInProgress || currentObject.fileDownloadState! == .eDownloadStatePaused || currentObject.fileDownloadState! == .eDownloadStateForcePaused {
                    dwonloadInprogress = true
                    break;
                }
            }
            if(dwonloadInprogress){
                return
            }
            else{
                pausedDownload = self.currentDownloadingArray.first
            }
        }
        if pausedDownload!.fileUrl != ""  {
            self.fetchAndUpdateTheDownloadURLForDownloadObject(withDownloadObject: pausedDownload, withDownloadObjectCurrentUrl: URL(string: pausedDownload!.fileUrl)!, withSuccess: {(_ downloadObjectUrl: String) -> Void in
                if !(downloadObjectUrl == pausedDownload!.fileUrl) {
                    pausedDownload!.fileUrl = downloadObjectUrl
                    self.updatePlist(forFile: pausedDownload!)
                }
                if(pausedDownload!.fileDownloadState != .eDownloadStateInProgress){
                    self.downloadNextObject(nextObject: pausedDownload!)
                }
            }, andFailure: {(_ error: Error?) -> Void in
                self.downloadNextObject(nextObject: thisObject)
            })
        }
    }

    func getCurrentDownloadStateForFile(withFileID fileId: String) -> Int {
        var downloadState: Int = 3
        for thisObject: DownloadObject in self.globalDownloadArray {
            if (fileId == thisObject.fileID) {
                downloadState = thisObject.fileDownloadState!.rawValue
                break
            }
        }
        return downloadState
    }

    func updatePlist(forFile downloadObject: DownloadObject) {
        self.storageManager.updatePlistFileContent(forFileName: downloadObject.fileID, andObject: downloadObject)
    }

    //MARK: TCBlobDownloader Delegate
    func download(_ blobDownload: TCBlobDownloader, didFinishWithSuccess downloadFinished: Bool, atPath pathToFile: String) {
        if downloadFinished {
            var ii: Int = 0
            var index: Int = 0
            for thisObject: DownloadObject in currentDownloadingArray {
                if (blobDownload.fileName == "\(thisObject.fileID).mp4") {
                    index = (currentDownloadingArray as NSArray).index(of: thisObject)
                    break
                }
                ii += 1
            }
            if index > currentDownloadingArray.count {
                return
            }
            let downloadedObject: DownloadObject? = (currentDownloadingArray[index])
            downloadedObject?.fileDownloadState = .eDownloadStateFinished
            self.downloadedArray.append(downloadedObject!)
            self.currentSessiondownloadedArray.append(downloadedObject!)
            //Update plist on download completion.
            self.storageManager.updatePlistFileContent(forFileName: (downloadedObject?.fileID)!, andObject: downloadedObject!)
            self.currentDownloadingArray.remove(at: index)
            self.updateGlobalDownloadArray()
            var isSubTitleUrlValid:Bool = false
            var srtsubTitleURL:URL!
            if downloadedObject?.closedCaptions != nil {
                if let subTitles = downloadedObject?.closedCaptions {
                    
                    if (subTitles.count > 0) {
                        
                        let subTitleArray:Array<SFSubtitle>? = subTitles.allObjects as? Array<SFSubtitle>
                        
                        if subTitleArray != nil {
                            
                            for subTitleObj in subTitleArray! {
                                
                                if !subTitleObj.subTitleType.isEmpty {
                                    
                                    if subTitleObj.subTitleType.lowercased() == "srt" {
                                        
                                        srtsubTitleURL = URL(string: Utility.urlEncodedString_ch(emailStr: subTitleObj.subTitleUrl))
                                        
                                        if srtsubTitleURL != nil {
                                            
                                            if srtsubTitleURL!.absoluteString != "" {
                                                
                                                isSubTitleUrlValid  = true
                                                break
                                            }
                                        }
                                    }
                                }
                                else {
                                    
                                    srtsubTitleURL = URL(string: Utility.urlEncodedString_ch(emailStr: subTitleObj.subTitleUrl))
                                    
                                    if srtsubTitleURL != nil {
                                        
                                        if srtsubTitleURL!.absoluteString != "" {
                                            
                                            isSubTitleUrlValid  = true
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if(isSubTitleUrlValid){
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let request = URLRequest(url:srtsubTitleURL!)
                self.createDownloadTaskForSubTitle(srtRequest: request, srtSession: session,downloadedObject: downloadedObject! ,pathToFile:pathToFile as NSString)
            }
            
            self.downloadDelegate?.downloadFinished(for: downloadedObject!)
            
            let userInfo:Dictionary<String, Any> = [Constants.kDownloadObject:downloadedObject!]
            NotificationCenter.default.post(name: Notification.Name(Constants.kDownloadFinished), object: nil, userInfo: userInfo)
            
            self.updateGlobalDownloadProgress(withFinished: true)
            if self.currentDownloadingArray.count > 0 {
                self.downloadNextObject(nextObject: nil)
            }

            /*
             if downloadedObject != nil {
             GAI.sharedInstance().defaultTracker().send(GAIDictionaryBuilder.createEvent(withCategory: "Offline Viewing", action: "Download Finished", label: downloadedObject?.fileID, value: nil)?.build())
             }
             */
        }
        else {
            self.isThereIsDownloadInProgress = false
            self.globalDownloadDelegate?.errorOccuredForDownload()
            var ii: Int = 0
            var index: Int = 0
            for thisObject: DownloadObject in currentDownloadingArray {
                if (blobDownload.fileName == "\(thisObject.fileID).mp4") {
                    index = (currentDownloadingArray as NSArray).index(of: thisObject)
                }
                ii += 1
            }
            if  !(index > currentDownloadingArray.count) {
                let downloadErrorObject: DownloadObject? = (self.currentDownloadingArray[index])
                self.removeObject(fromDownloadedArray: (downloadErrorObject?.fileID)!, withSuccessBlock: {() -> Void in
                }, andFailureBlock: {(_ error: Error?) -> Void in
                })
            }
        }
    }
    
    func createDownloadTaskForSubTitle(srtRequest: URLRequest, srtSession:URLSession, downloadedObject:DownloadObject, pathToFile:NSString)  {
        let task = srtSession.downloadTask(with: srtRequest) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    //Copy srt same path as download
                    try FileManager.default.copyItem(at: tempLocalUrl, to: NSURL.fileURL(withPath: pathToFile.replacingOccurrences(of: "mp4", with: "srt")))
                    
                } catch (let writeError) {
                    print("Error creating a file \(pathToFile) : \(writeError)")
                    
                }
                
            }
        }
        task.resume()
        
        
    }


    func download(_ blobDownload: TCBlobDownloader, didReceiveData receivedLength: UInt64, onTotal totalLength: UInt64, progress: Float) {
        if (self.currentDownloadingArray.count == 0) {
            return
        }
        var ii: Int = 0
        var index: Int = 0
        for thisObject: DownloadObject in self.currentDownloadingArray {
            if (blobDownload.fileName == "\(thisObject.fileID).mp4") {
                index = (self.currentDownloadingArray as NSArray).index(of: thisObject)
            }
            ii += 1
        }
        if index >= currentDownloadingArray.count {
            return
        }
        let downloadingObject: DownloadObject? = (self.currentDownloadingArray[index])
        downloadingObject?.fileCurrentDownloadedLength = Double(receivedLength)
        downloadingObject?.fileTotalLength = Double(totalLength)
        downloadingObject?.fileDownloadState = .eDownloadStateInProgress
        self.downloadDelegate?.updateDownloadProgress(for: downloadingObject!, withProgress: progress)
        
        let userInfo:Dictionary<String, Any> = [Constants.kDownloadObject:downloadingObject!,Constants.kDownloadProgress:progress]
        NotificationCenter.default.post(name: Notification.Name(Constants.kUpdateDownloadProgress), object: nil, userInfo: userInfo)
        
        self.updateGlobalDownloadProgress(withFinished: false)
        self.isDownloadingPaused = false
    }

    func download(_ blobDownload: TCBlobDownloader, didReceiveFirstResponse response: URLResponse) {
        var ii: Int = 0
        var index: Int = 0
        for thisObject: DownloadObject in self.currentDownloadingArray {
            if (blobDownload.fileName == "\(thisObject.fileID).mp4") {
                index = (self.currentDownloadingArray as NSArray).index(of: thisObject)
            }
            ii += 1
        }
        print(index)
        self.isThereIsDownloadInProgress = true
        self.globalDownloadDelegate?.downloadStartForAnObject()
    }

    func download(_ blobDownload: TCBlobDownloader, didStopWithError error: Error?) {
        var ii: Int = 0
        var index: Int = 0
        for thisObject: DownloadObject in self.currentDownloadingArray {
            if (blobDownload.fileName == "\(thisObject.fileID).mp4") {
                index = (self.currentDownloadingArray as NSArray).index(of: thisObject)
                thisObject.fileDownloadState = .eDownloadStatePaused
                updatePlist(forFile: thisObject)
                break
            }
            ii += 1
        }
        if error?.code == 2 {
            self.showMemoryWarningAlert()
        }
        if index >= self.currentDownloadingArray.count {
            return
        }
        self.downloadDelegate?.downloadFailed(for:currentDownloadingArray[index])
        let userInfo:Dictionary<String, Any> = [Constants.kDownloadObject:currentDownloadingArray[index]]
        NotificationCenter.default.post(name: Notification.Name(Constants.kDownloadFailed), object: nil, userInfo: userInfo)
        /*
        let downloadedObject: DownloadObject? = (currentDownloadingArray[index] )
        GAI.sharedInstance().defaultTracker().send(GAIDictionaryBuilder.createEvent(withCategory: "Offline Viewing", action: "Download Failed", label: downloadedObject?.fileID, value: nil)?.build())
        */
    }
    func updatePlist(forFileWatchedPercentage fileID: String, watchedPercentage: Float) {
        self.updateWatchedPercentageForDownloadObject(withID: fileID, andWatchedPercentage: watchedPercentage)
        self.storageManager.updateFile(fileID, watchedPercentage: watchedPercentage)
    }

    func getMP4UrlPathForTheDownloadObject(forFileId fileId: String) -> String {
        return self.storageManager.getMP4UrlPathForTheDownloadObject(forFileId: fileId)
    }
    func getSubTitleFilePathForTheDownloadObject(forFileId fileId: String) -> String {
        return self.storageManager.getSubTitleFilePathForTheDownloadObject(forFileId: fileId)
    }


    func getFilePathForTheDownloadObject(forFileId fileId: String) -> String {
        return self.storageManager.getFilePathForTheDownloadObject(forFileId: fileId)
    }

    func updateWatchedPercentageForDownloadObject(withID downloadObjectID: String, andWatchedPercentage watchedPerentage: Float) {
        for downloadObj: DownloadObject in downloadedArray {
            if (downloadObj.fileID == downloadObjectID) {
                downloadObj.fileWatchedPercentage = watchedPerentage
                break
            }
        }
        self.updateGlobalDownloadArray()
    }

    func isThereADownloadingInProgress() -> Bool {
        var isDownloadingInProgress: Bool = false
        if self.currentSessionDownloadingArray.count > 0 && self.isThereIsDownloadInProgress {
            isDownloadingInProgress = true
        }
        return isDownloadingInProgress
    }

    func getGlobalProgressForAllDownloads() -> Float {
        if self.currentDownloadingArray.count > 0 {
            return self.calculateDownloadLengthOfDownload() / self.calculateTotalLengthOfDownload()
        }
        else {
            return 0.0
        }
    }

    func isAnyDownloadInProgress() -> Bool {
        return !self.isDownloadingPaused
    }

    func updateDocumentsDirectoryPathForTheDownloadedItems() {
        if self.currentDownloadingArray.count > 0 {
            for downloadObjectAtIndex: DownloadObject in self.currentDownloadingArray {
                if downloadObjectAtIndex.fileDownloadState == .eDownloadStateFinished {
                    downloadObjectAtIndex.filePathUrl = self.getFilePathForTheDownloadObject(forFileId: downloadObjectAtIndex.fileID)
                }
                updatePlist(forFile: downloadObjectAtIndex)
            }
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
}
