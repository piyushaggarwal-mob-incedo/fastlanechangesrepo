//
//  KisweBaseViewController.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 11/6/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import KMSDK

class KisweBaseViewController: UIViewController,KMMediaControllerDelegate {
    var eventID : String?
    var filmId : String?
    private var objMediVC : KMParentViewController?
    private var durationTimer : Timer?
    private var progressIndicator:MBProgressHUD?
    weak var delegate:SFKisweBaseViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        self.createNavigationBar()
        if(self.eventID != nil && self.filmId != nil){
            self.presentKiswePlayerForEventId(eventId: self.eventID!, filmId: self.filmId!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        else{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(objMediVC != nil){
            objMediVC?.mediaPlayerController.playerView?.player?.pause()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
            else{
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }) { (context) in
            if self.objMediVC != nil{
                self.view.bringSubview(toFront: (self.objMediVC?.mediaPlayerController.playerView)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchUserDetailModuleContent(success: @escaping ((_ userResult: SFUserDetails?) -> Void))  {

        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"

        DataManger.sharedInstance.fetchUserPageDetails(apiEndPoint: apiRequest) { (userResult, isSuccess) in
            if userResult != nil && isSuccess {
                success(userResult)
            }
            else
            {
                success(nil)
            }
        }
    }

    func presentKiswePlayerWith(userName: String) -> Void {
        KMSDK.shared.parentViewControllerWith(eventId: self.eventID!, username: userName) { (parentVC) in
            self.removeActivityIndicator()
            if let parentVC = parentVC {
                if (self.filmId != nil) {
                    GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Play Movie", action: "Movie ID", label: self.filmId, value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
                    GAI.sharedInstance().defaultTracker.allowIDFACollection = true
                }
                parentVC.view.frame = self.view.bounds
                Constants.kSTANDARDUSERDEFAULTS.setValue(self.filmId, forKey: Constants.kKisweFilmId)
                self.objMediVC = parentVC
                parentVC.mediaPlayerController.delegate = self
                self.startDurationTimer()
                parentVC.mediaPlayerController.playerControls.buttonBack.removeTarget(nil, action: nil, for: .allEvents)
                parentVC.mediaPlayerController.playerControls.buttonBack.addTarget(self, action: #selector(self.playerBackButtonPressed(sender:)), for: .touchUpInside)
                self.view.addSubview(parentVC.view)
                self.addChildViewController(parentVC)
            }
            else{
                let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: {(_ action: UIAlertAction) -> Void in
                    DispatchQueue.main.async {
                        UIApplication.shared.isStatusBarHidden = false
                        Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                        self.navigateBack()
                        self.dismiss(animated: true) {
                        }
                    }
                })
                let alertController:UIAlertController = UIAlertController(title: "Error", message: "Could not get Event", preferredStyle: .alert)
                alertController.addAction(okAction)
                self.present(alertController as UIViewController, animated: true) { _ in }
            }
        }
    }

    /// Method to present the Kiswe player
    ///
    /// - Parameters:
    ///   - eventId: EventId
    ///   - filmId: FilmId for video
    ///   - viewController: viewcontroller instance in which kisweplayer will appear.
    func presentKiswePlayerForEventId(eventId:String, filmId:String) -> Void {
        self.addActivityIndicator()
        var userName = "Guest"
        if Utility.sharedUtility.checkIfUserIsLoggedIn(){
            self.fetchUserDetailModuleContent(success: { (userDetails) in
                if let userDetails = userDetails {
                    if let emailId = userDetails.emailID{
                        userName = emailId
                    }
                    else if let name = userDetails.name{
                        userName = name
                    }
                }
                userName = userName.lowercased();
                self.presentKiswePlayerWith(userName: userName)
            })
        }
        else{
            userName = userName.lowercased();
            self.presentKiswePlayerWith(userName: userName)
        }
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    func addActivityIndicator() -> Void {
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
    }

    func removeActivityIndicator() -> Void {
         progressIndicator?.hide(animated: true)
    }
    
    func createNavigationBar() -> Void {
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        let backButton: UIButton = UIButton.init(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "Back Chevron.png"), for: .normal)
        backButton.tintColor = UIColor.white
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 60, height: 22)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 4,left: 0,bottom: 4,right: 50)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: -25,bottom: 0,right: 0)
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        let backBarButtonItem: UIBarButtonItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
    }
    func navigateBack() -> Void {
        if delegate != nil {
            if (delegate?.responds(to: #selector(SFKisweBaseViewControllerDelegate.removeKisweBaseViewController(viewController:))))! {
                delegate?.removeKisweBaseViewController!(viewController: self)
            }
        }
    }
    func backButtonTapped(sender: UIButton) -> Void {
        self.navigateBack()
        self.dismiss(animated: true) {
        }
    }

    func startDurationTimer() -> Void {
        self.stopDurationTimer()
        durationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(monitorMoviePlayback(sender:)), userInfo: nil, repeats: true)
    }

    func stopDurationTimer() -> Void {
        if durationTimer != nil {
            durationTimer?.invalidate()
            durationTimer = nil
        }
    }

    func playerBackButtonPressed(sender: UIButton) -> Void {
        DispatchQueue.main.async(execute: {() -> Void in
            if Constants.IPHONE {
                Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            self.stopDurationTimer()
            self.navigateBack()
            self.dismiss(animated: true, completion: {() -> Void in
                if self.objMediVC != nil {
                    self.objMediVC?.mediaPlayerController.playerView?.player?.pause()
                    self.objMediVC?.removeFromParentViewController()
                    self.objMediVC = nil
                }
            })
        })
    }

    func monitorMoviePlayback(sender: Timer) -> Void {
        if self.objMediVC != nil && Double((self.objMediVC?.mediaPlayerController.playerView?.player?.rate)!) > 0.0 {
            let currentTime: Double = CMTimeGetSeconds((self.objMediVC?.mediaPlayerController.playerView?.player?.currentTime())!)
            let filmID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kKisweFilmId) as? String
            print("current time of player  -----   \(currentTime)")
            let currentTimeInt = Int(currentTime)
            if currentTimeInt > 0 && filmID != nil {
                if currentTimeInt % 30 == 0 {
                    var beaconDict : Dictionary<String,String> = [:]
                    beaconDict[Constants.kBeaconVidKey] = filmID
                    beaconDict[Constants.kBeaconUrlKey] = "KiswePlayerView"
                    beaconDict[Constants.kBeaconRefKey] = "KiswePlayer"
                    beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypePlay
                    beaconDict[Constants.kBeaconVposKey] = String(currentTime)
                    let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
                    DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
                }
            }
        }
    }
}
