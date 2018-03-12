//
//  RoundProgressBar.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/17/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//
import Foundation
import UIKit

extension UIAlertController {

    func show() {
        present(animated: true, completion: nil)
    }

    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }

    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
}

extension UINavigationController {

    func present() {
        present(animated: true, completion: nil)
    }

    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }

    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
}

class RoundProgressBar: UIView, UIAlertViewDelegate {
    /*!
     * @brief SFRoundProgressIndicator object. Used for creating downloading progress bar.
     */
    var roundProgressView: SFRoundProgressIndicator?
    /*!
     * @brief UIView object. Acts as background view for downloading progress bar.
     */
    var roundProgressViewBackgroundView: UIView?
    /*!
     * @brief UIButton object. Used as download, pause and resume button.
     */
    var downloadButton: UIButton?
    /*!
     * @brief UIImageView object. Used display download complete status.
     */
    var cloudIconOnComplete: UIImageView?
    /*!
     * @brief DownloadObject object. Conatains downloading object.
     */
    var downloadObject: DownloadObject?
    /*!
     * @brief SFFilm object. Conatains downloading object.
     */
    var filmObject: SFFilm?
    /*!
     * @brief viewController property conatains refrence of current view controller on which download icon is tabbed.
     */
    weak var viewController: UIViewController?

    var senderButton: UIButton?
    var resumeDownloading: Bool = false
    var activityIndicator: UIActivityIndicatorView?
    var progressIndicator:MBProgressHUD?
    /*!
     * @discussion - Create initial setup of the Progress Bar. It is a mandatory method. Required to be called when download progress bar needs to be added.
     */

    init(with downlodObj:DownloadObject) {
        super.init(frame: CGRect.zero)
        self.downloadObject = downlodObj
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func check(forNetwork notification: Notification) {
        check(forInternetConnection: true)
    }

    func check(forInternetConnection isReachabilityChanged: Bool) {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            if isReachabilityChanged && reachability.currentReachabilityStatus() == ReachableViaWiFi {
                if self.downloadObject?.fileDownloadState == .eDownloadStatePaused {
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadObject!)
                    //downloadObject?.fileDownloadState = .eDownloadStateInProgress
                    DispatchQueue.main.async(execute: {() -> Void in
                        self.downloadButton?.isSelected = true
                    })
                }
            }
            else if isReachabilityChanged && reachability.currentReachabilityStatus() == ReachableViaWWAN {
                if Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kCellularDownload) {
                    if self.downloadObject?.fileDownloadState == .eDownloadStatePaused {
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        //self.downloadObject?.fileDownloadState = .eDownloadStateInProgress
                        DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadObject!)
                    }
                }
                else{

                if self.downloadObject?.fileDownloadState == .eDownloadStateInProgress {
                    DownloadManager.sharedInstance.pauseDownloadingObject(isForcePaused: false)
                }
                DispatchQueue.main.async(execute: {() -> Void in
                    self.downloadButton?.isSelected = false
                })
                }
            }

            self.downloadButton?.tag = 200
            self.downloadButton?.alpha = 1.0
            self.roundProgressView?.alpha = 1.0
            //roundProgressView?.tintColor = Utility.color(fromHex: "#F5181C")
        }
        else {
            self.downloadButton?.tag = 404
            self.downloadButton?.alpha = 0.95
            self.roundProgressView?.alpha = 0.5
            
            if self.downloadObject?.fileDownloadState == .eDownloadStateInProgress {
                self.downloadObject?.fileDownloadState = .eDownloadStatePaused
            }
            //roundProgressView?.tintColor = Utility.color(fromHex: "#F5181C")
            DispatchQueue.main.async(execute: {() -> Void in
                self.downloadButton?.isSelected = false
                self.networkNotAvailable()
            })
        }
    }

    func removeNotifications() throws {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    /*!
     * @discussion - Create initial setup of the Progress Bar.
     */
    func initialize() {
        defer {
            NotificationCenter.default.addObserver(self, selector:#selector(check(forNetwork:)), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        }
        do {
            try self.removeNotifications()
        }
        catch {
            print("Encountered error \(error)")
        }
        self.roundProgressViewBackgroundView = UIView()
        self.roundProgressViewBackgroundView?.backgroundColor = UIColor.clear
        self.addSubview(roundProgressViewBackgroundView!)
        self.roundProgressView = SFRoundProgressIndicator()
        self.roundProgressView?.setStartAngle((3.0 * .pi) / 2.0)
        //roundProgressView?.tintColor = Utility.color(fromHex: "#F5181C")
        self.addSubview(roundProgressView!)
        self.downloadButton = UIButton()
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.downloadButton?.setImage(UIImage(named: "download.png"), for: .normal)
            self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
        }
        else {
            self.downloadButton?.setImage(UIImage(named: "download.png"), for: .normal)
            self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
        }
        self.downloadButton?.addTarget(self, action: #selector(self.downloadButtonTapped(sender:)), for: .touchUpInside)
        self.addSubview(downloadButton!)
        self.downloadButton?.isUserInteractionEnabled = true
        self.cloudIconOnComplete = UIImageView()
        self.cloudIconOnComplete?.image = UIImage(named: "downloaded.png")
        self.cloudIconOnComplete?.contentMode = .scaleAspectFit
        self.addSubview(cloudIconOnComplete!)
        self.cloudIconOnComplete?.isHidden = true
        self.setNeedsLayout()
        self.check(forInternetConnection: true)
    }

    override func setNeedsLayout() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.roundProgressViewBackgroundView?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            self.roundProgressViewBackgroundView?.clipsToBounds = true
            self.setRoundedView(roundProgressViewBackgroundView!, toDiameter: Float(roundProgressViewBackgroundView!.frame.size.height))
            self.roundProgressView?.frame = CGRect(x: 1, y: 1, width: 25, height: 25)
            self.cloudIconOnComplete?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            self.downloadButton?.frame = (roundProgressView?.frame)!
        }
        else {
            self.roundProgressViewBackgroundView?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            self.roundProgressViewBackgroundView?.clipsToBounds = true
            self.setRoundedView(roundProgressViewBackgroundView!, toDiameter: Float(roundProgressViewBackgroundView!.frame.size.height))
            self.roundProgressView?.frame = CGRect(x: 1, y: 1, width: 25, height: 25)
            self.cloudIconOnComplete?.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            self.downloadButton?.frame = (roundProgressView?.frame)!
        }
    }
    
    
    /*!
     * @discussion -  Method to round the background view of progress bar.
     * @param UIView -  view that needs to be rounded.
     * @param float - diameter of rounded view.
     */
    func setRoundedView(_ roundedView: UIView, toDiameter newSize: Float) {
        let saveCenter: CGPoint = roundedView.center
        let newFrame = CGRect(x: roundedView.frame.origin.x, y: roundedView.frame.origin.y, width: CGFloat(newSize), height: CGFloat(newSize))
        roundedView.frame = newFrame
        roundedView.layer.cornerRadius = CGFloat(newSize / 2.0)
        roundedView.center = saveCenter
    }

    func qualityExistsForFilm() -> Bool {
        var isFound = false
        for filmUrl in (self.filmObject?.filmUrl)! {
            let filmUrlObject: SFFilmURL = filmUrl as! SFFilmURL
            if filmUrlObject.renditionValue.contains(DownloadManager.sharedInstance.downloadQuality){
                isFound = true
                break
            }
        }
        return isFound
    }


    func monitorObserver(notification: NSNotification) -> Void {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)
        
        let obj:String = notification.object as! String
        if obj == "continueButton" {
            if (DownloadManager.sharedInstance.downloadQuality != ""){
                DispatchQueue.main.async{
                    self.startDownload()
                }
            }
        }
    }

    func showAlertForGuestUser() -> Void {
        var alertTitle = ""
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            alertTitle = "You have to be a subscriber to download this movie."
        }
        else{
            alertTitle = "You have to login to download this movie."
        }

        let alertController = UIAlertController(title: "Download Movie", message: alertTitle, preferredStyle: .alert)

        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default, handler: {(_ action: UIAlertAction) -> Void in

            self.displayLoginScreen()
        })

        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
        })

        alertController.addAction(cancelAction)
        alertController.addAction(signInAction)

        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            let startFreeTrialAction = UIAlertAction(title: Constants.kStartFreetrial, style: .default, handler: {(_ action: UIAlertAction) -> Void in
                let planViewController:SFProductListViewController = SFProductListViewController.init()
                let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
                navigationController.present()
            })
            alertController.addAction(startFreeTrialAction)
        }
        alertController.show()
    }

    func displayLoginScreen() -> Void {

        displayLoginViewWithCompletionHandler() { (isSuccessfullyLoggedIn) in

            if isSuccessfullyLoggedIn {
                self.startDownload()
            }
        }
    }

    func displayLoginViewWithCompletionHandler(completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {

        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        loginViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        navigationController.present()
    }

    func startDownload() -> Void {
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            self.resumeDownloading = false
            if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: (self.filmObject?.id)!) {
                self.addActivityIndicator()
                if self.senderButton != nil {
                    
                    if (self.senderButton?.isSelected)! {
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        
                        DownloadManager.sharedInstance.pauseDownloadingObject(isForcePaused: true)
                        DispatchQueue.main.async{
                            self.senderButton?.isSelected = false
                            self.removeActivityIndicator()
                        }
                    }
                    else {
                        
                        self.resumeDownloading = true
                        let reachability:Reachability = Reachability.forInternetConnection()
                        if reachability.currentReachabilityStatus() == NotReachable {
                            self.networkNotAvailable()
                            self.removeActivityIndicator()
                            return
                        }
                        else if reachability.currentReachabilityStatus() == ReachableViaWWAN {

                            Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.downloadingFromCellularNetwork()
                            self.removeActivityIndicator()
                            return
                        }

                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadObject!)
                        self.setTheProgressForItemForDownloadProgress(filmObject!)
                        DispatchQueue.main.async{
                            self.senderButton?.isSelected = true
                           self.removeActivityIndicator()
                        }
                    }
                }
                else {
                    
                    self.resumeDownloading = true
                    let reachability:Reachability = Reachability.forInternetConnection()
                    if reachability.currentReachabilityStatus() == NotReachable {
                        
                        self.networkNotAvailable()
                        self.removeActivityIndicator()
                        return
                    }
                    else if reachability.currentReachabilityStatus() == ReachableViaWWAN {
                        
                        self.downloadingFromCellularNetwork()
                        self.removeActivityIndicator()
                        return
                    }
                    
                    DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadObject!)
                    self.setTheProgressForItemForDownloadProgress(filmObject!)
                    self.removeActivityIndicator()
                    //Commented: As sender button is coming as nil
//                    DispatchQueue.main.async{
//                        self.senderButton?.isSelected = true
//                    }
                }
            }
            else {
                
                self.startDownloadForTheLectureOnDownloadTap()
                self.removeActivityIndicator()
            }
        }
        else{
            self.showAlertForGuestUser()
        }
    }

    func downloadButtonTapped(sender: UIButton) -> Void {
        if sender.tag == 404 {
            return
        }
        self.senderButton = sender
        self.startDownload()
    }

    func startDownloadForTheLectureOnDownloadTap() {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            self.networkNotAvailable()
            return
        }
        else if reachability.currentReachabilityStatus() == ReachableViaWWAN{
            self.downloadingFromCellularNetwork()
            return
        }
        self.startDownloadingOfObject()
    }

    func setTheProgressForItemForDownloadProgress(_ filmObject: SFFilm) {
        self.filmObject = filmObject
        self.downloadButton?.isUserInteractionEnabled = true
        self.downloadButton?.isEnabled = true
        self.roundProgressView?.setProgress(DownloadManager.sharedInstance.getDownloadProgress(forObject: filmObject.id!))
        
        let state:downloadObjectState = downloadObjectState(rawValue: DownloadManager.sharedInstance.getCurrentDownloadStateForFile(withFileID: filmObject.id!))!
        
        if DownloadManager.sharedInstance.getDownloadProgress(forObject: filmObject.id!) != 1.0 && DownloadManager.sharedInstance.getDownloadingObjectsArray().count > 0 && state == .eDownloadStateInProgress {
            self.downloadButton?.isSelected = true
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.downloadButton?.setImage(UIImage(named: "gridDownload.png"), for: .normal)
                self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
            }
            else {
                self.downloadButton?.setImage(UIImage(named: "gridDownload.png"), for: .normal)
                self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
            }
            self.cloudIconOnComplete?.isHidden = true
            self.downloadButton?.isHidden = false
            self.downloadButton?.isUserInteractionEnabled = true
            self.roundProgressView?.isHidden = false
            self.roundProgressViewBackgroundView?.isHidden = false
        }
        else {
            if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: (self.filmObject?.id)!) {
                self.downloadButton?.isSelected = false
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.downloadButton?.setImage(UIImage(named: "gridDownload.png"), for: .normal)
                    self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                }
                else {
                    self.downloadButton?.setImage(UIImage(named: "gridDownload.png"), for: .normal)
                    self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                }
                self.cloudIconOnComplete?.isHidden = true
                self.roundProgressView?.isHidden = false
                self.roundProgressViewBackgroundView?.isHidden = false
                
                if state == .eDownloadStateFinished {
                    self.downloadButton?.isHidden = true
                    self.cloudIconOnComplete?.isHidden = false
                    self.roundProgressView?.isHidden = true
                    self.roundProgressViewBackgroundView?.isHidden = true
                }
                else if state == .eDownloadStateQueued {
                    self.downloadButton?.isHidden = false
                    self.downloadButton?.isSelected = false
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        self.downloadButton?.setImage(UIImage(named: "icon_download_enque.png"), for: .normal)
                        self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                    }
                    else {
                        self.downloadButton?.setImage(UIImage(named: "icon_download_enque.png"), for: .normal)
                        self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                    }
                    self.cloudIconOnComplete?.isHidden = true
                    self.roundProgressView?.isHidden = true
                    self.roundProgressViewBackgroundView?.isHidden = true
                    self.downloadButton?.isEnabled = false
                    self.downloadButton?.isUserInteractionEnabled = false
                }
            }
            else {
                self.downloadButton?.isHidden = false
                self.downloadButton?.isSelected = false
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.downloadButton?.setImage(UIImage(named: "download.png"), for: .normal)
                    self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                }
                else {
                    self.downloadButton?.setImage(UIImage(named: "download.png"), for: .normal)
                    self.downloadButton?.setImage(UIImage(named: "offline_pause.png"), for: .selected)
                }
                self.cloudIconOnComplete?.isHidden = true
                self.roundProgressView?.isHidden = true
                self.roundProgressViewBackgroundView?.isHidden = true
            }
        }
    }

    //MARK: Method to check if user is entitled or not
    func checkIfUserIsEntitledToVideo() {

        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {

            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                
                self.addActivityIndicator()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                        
                        DispatchQueue.main.async {
                        
                            if isSubscribed != nil {
                                
                                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                    
                                    Utility.sharedUtility.setGTMUserProperty(userPropertyValue: isSubscribed! ? Constants.kGTMSubscribedPropertyValue : Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                }
                                
                                if isSubscribed! {
                                    
                                    self.resumeDownload()
                                }
                                else {
                                    
                                    self.removeActivityIndicator()
                                    
                                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                    
                                    self.displayNonEntitledUserAlert()
                                }
                            }
                            else {
                                
                                self.removeActivityIndicator()
                                
                                Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                
                                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                    
                                    Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                }
                                
                                self.displayNonEntitledUserAlert()
                            }
                        }
                    })
                }
            }
            else {
                
                self.resumeDownload()
            }
        }
        else {
            self.showAlertForGuestUser()
        }
    }

    
    func resumeDownload() {
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey) != nil  {
            DownloadManager.sharedInstance.downloadQuality = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey) as! String
        }
        
        if (DownloadManager.sharedInstance.downloadQuality == "") {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(monitorObserver(notification:)), name: NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)

            self.removeActivityIndicator()
            let downloadQualityViewController = DownloadQualityViewController()
            let navEditorViewController: UINavigationController = UINavigationController(rootViewController: downloadQualityViewController)
            navEditorViewController.modalPresentationStyle = .overFullScreen
            navEditorViewController.present()
            return
        }
        
        self.displayAlertToDownloadLecture()
    }
    
    
    /*!
     * @discussion - This method will add an Object to Downloading list.
     */
    func startDownloadingOfObject() {
        //self.addActivityIndicator()
        self.downloadButton?.isEnabled = false
        self.downloadButton?.isUserInteractionEnabled = false
        self.checkIfUserIsEntitledToVideo()
    }

    func displayNonEntitledUserAlert() {
        self.downloadButton?.isEnabled = true
        self.downloadButton?.isUserInteractionEnabled = true
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
        }

        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            let planViewController:SFProductListViewController = SFProductListViewController.init()
            let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
            navigationController.present()
        }

        var alertActionArray:Array<UIAlertAction>?
        alertActionArray = [cancelAction, subscriptionAction]

        var alertTitle = ""
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            alertTitle = "You have to be a subscriber to download this movie."
        }
        else{
            alertTitle = "You have to login to download this movie."
        }

        let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: alertTitle, alertActions: alertActionArray!)
        nonEntitledAlert.show()
    }


    func showAlertForUnSubscribedUser() {
        let alertController = UIAlertController(title: Constants.kStartFreetrial, message: Constants.kStartFreetrialMessage, preferredStyle: .alert)
        let noAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("noAction")
        })
        let yesAction = UIAlertAction(title: Constants.kStartFreetrial, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Yes action")
            let productListVC = SFProductListViewController()
            UIApplication.shared.keyWindow?.rootViewController?.navigationController?.present(productListVC, animated: true, completion: {
            })
        })
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        alertController.show()
    }

    func showAlertForSubscribedUser() {
        let alertController = UIAlertController(title: Constants.kStartFreetrial, message: Constants.kUpgradeYourPlanMessage, preferredStyle: .alert)
        let noAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("noAction")
        })
        let yesAction = UIAlertAction(title: Constants.kManageSubsubcription, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Yes action")
            UIApplication.shared.openURL(URL(string: Constants.kStoreURL)!)
        })
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        alertController.show()
    }

    func updateFramesOnOrientation() {
    }

    /*!
     * @discussion - Method called to update the progress view while downloading.
     * @param DownloadObject - download object for which progess needs to be updated.
     * @param float - updated progress value.
     */

    func updateTheCircularProgress(for downloadObject: DownloadObject, withProgress progress: Float) {
        DispatchQueue.global(qos: .userInitiated).async(execute: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                self.roundProgressView?.setProgress(progress)
                print("setProgress:progress >>   \(progress)")
                if progress == 1.0 {
                    self.cloudIconOnComplete?.isHidden = false
                    self.downloadButton?.isHidden = true
                    self.downloadButton?.isUserInteractionEnabled = false
                    self.roundProgressView?.isHidden = true
                    self.roundProgressViewBackgroundView?.isHidden = true
                }
                else {
                    self.cloudIconOnComplete?.isHidden = true
                    self.downloadButton?.isHidden = false
                    self.downloadButton?.isUserInteractionEnabled = true
                    self.roundProgressView?.isHidden = false
                    self.roundProgressViewBackgroundView?.isHidden = false
                }
            })
        })
    }

    /*!
     *@brief Promt user before downloading lecture.
     */

    func displayAlertToDownloadLecture() {
        
        DispatchQueue.main.async {
            
//            if self.filmObject != nil && (self.filmObject?.filmUrl.count ?? 0) > 0 {
//                
//                self.downloadVideoIfUrlAvailable()
//            }
//            else {
                
                if self.filmObject?.id != nil {
                    
                    let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\((self.filmObject?.id)!)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo"
                    DataManger.sharedInstance.fetchDownloadURLDetailsForVideo(apiEndPoint: apiEndPoint, filmObject: self.filmObject!, filmResponse: { (updatedFilmObject) in
                        
                        self.filmObject = updatedFilmObject
                        self.downloadVideoIfUrlAvailable()
                    })
                }
//            }
        }
    }

    
    private func downloadVideoIfUrlAvailable() {
        
        self.removeActivityIndicator()
        self.downloadObject = DownloadManager.sharedInstance.getDownloadObject(for: self.filmObject!, andShouldSaveToDirectory: true)
        if self.downloadObject?.fileUrl != "" && (self.downloadObject?.fileUrl.characters.count ?? 0) > 0 && (self.filmObject?.isLiveStream == false || self.filmObject?.isLiveStream == nil) {
            DispatchQueue.main.async {
                self.downloadButton?.isSelected = true
                if !DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: (self.filmObject?.id!)!) {
                    DownloadManager.sharedInstance.addObject(toDownload: self.downloadObject!)
                    self.setTheProgressForItemForDownloadProgress(self.filmObject!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DownloadStarted"), object: nil)
                }
            }
        }
    }
    /*!
     *@brief navigateToSettingScreen method allow user to navigate to home screen so that user can turn on
     *downloading from cellular netwok If wifi network is not available.
     *@param nil.
     */
    func navigateToSettingScreen() {
   
    }

    /*!
     * @brief networkNotAvailable method promt user if network is not available.
     * @param nil.
     */
    func networkNotAvailable() {
        if(DownloadManager.sharedInstance.currentDownloadingArray.isEmpty == false){
            let currentDownloadObject : DownloadObject? = (DownloadManager.sharedInstance.currentDownloadingArray[0])
            let alertController = UIAlertController(title: "Internet Connection", message: "\((currentDownloadObject?.fileName) ?? "Video") stopped downloading. Please try again when connected to wi-fi or enable cellular data.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Constants.kStrClose, style: .default, handler: {(_ action: UIAlertAction) -> Void in

            })
            alertController.addAction(cancelAction)
            alertController.show()
        }
    }

    /*!
     * @brief networkReachableViaWANN method promt user if network is reachable via cellualr data/mobile data.
     * @param nil.
     */
    func networkReachableViaWANN() {
        var fileName: String = (self.downloadObject?.fileName) ?? ""
        let message: String = "  cannot be downloaded. Please try again when connected to wi-fi or enable cellular data."
        var fileNameWithMessage = String()
        if fileName != "" {
            fileNameWithMessage = fileName + (message)
        }
        else {
            fileName = "This Video\(message)"
        }
        let alertController = UIAlertController(title: Constants.kInternetConnection, message: fileNameWithMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.kStrClose, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancel action")
        })
        let settingAction = UIAlertAction(title: Constants.kUseCellularData, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.navigateToSettingScreen()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingAction)
        alertController.show()
    }

    /*!
     * @brief downloadingFromCellularNetwork method warns user if downloading is done over cellular data.
     * @param nil.
     */

    func downloadingFromCellularNetwork() {
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) as! Bool
        {
            if self.resumeDownloading {
                DownloadManager.sharedInstance.resumeDownloadingObject(with: self.downloadObject!)
                self.setTheProgressForItemForDownloadProgress(self.filmObject!)
                DispatchQueue.main.async{
                    self.senderButton?.isSelected = true
                }
            }
            else {
                self.startDownloadingOfObject()
            }
        }
        else
        {
            let alertController = UIAlertController(title: "Use Cellular Data?", message: "Please update cellular download preference from your application settings", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            })
            let _ = UIAlertAction(title: "Use Cellular Data", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                if self.resumeDownloading {
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    DownloadManager.sharedInstance.resumeDownloadingObject(with: self.downloadObject!)
                    self.setTheProgressForItemForDownloadProgress(self.filmObject!)
                    DispatchQueue.main.async{
                        self.senderButton?.isSelected = true
                    }
                }
                else {
                    self.startDownloadingOfObject()
                }
            })
            alertController.addAction(cancelAction)
            alertController.show()
        }
        
    }
    
    
    //MARK: Activity Indicator Hide/Show method
    private func addActivityIndicator() -> Void {
        
        if let topController = Utility.sharedUtility.topViewController() {
            
            self.progressIndicator = MBProgressHUD.showAdded(to: topController.view, animated: true)
            self.progressIndicator?.label.text = ""
        }
    }
    
    
    private func removeActivityIndicator() -> Void {
        
        self.progressIndicator?.hide(animated: true)
    }
}
