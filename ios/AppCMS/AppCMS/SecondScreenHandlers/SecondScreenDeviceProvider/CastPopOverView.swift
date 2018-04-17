
//
//  CastViewController.swift
//  AppCMS
//
//  Created by Rajni Pathak on 17/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import GoogleCast
@objc protocol CastPopOverViewDelegate:NSObjectProtocol {
    
    @objc optional func didConnectToCastDevice()
    
    @objc optional func didDisConnectToCastDevice()
}

class CastPopOverView: NSObject, GCKDeviceManagerDelegate, GCKSessionManagerListener {
    
    static let shared = CastPopOverView()
    weak var delegate:CastPopOverViewDelegate?
    var deviceManager : GCKDeviceManager!
    var selectedDevice : GCKDevice!
    var chromecastButton : UIButton!
    var btnImage : UIImage!
    var btnImageSelected : UIImage!
    var presentVC : UIViewController!
    var listOfAvailableDevices = Array<Any>()
    var videoObject = VideoObject()
    var alertController: UIAlertController!
    private var sessionId:String?
//    func createCastButton() -> UIButton{
//        if(self.chromecastButton == nil){
//            self.chromecastButton = UIButton(type: .custom)
//        }
//        return self.chromecastButton
//    }

    func setCastPopOverViewDelegate(vc: UIViewController) -> Void {
        self.delegate = vc as? CastPopOverViewDelegate
    }

    /** func chooseDevice will display list of available devices with option to connect or discconect
     Params:
     chromeCastButton : UIButton (Chromecast Button Object)
     vc: UIViewController (ViewController from which cast Icon is tapped)
     
     */
    func updateAlertFramesOnOrientation(chromeCastButton: UIButton, vc: UIViewController)  {
        if(alertController != nil){
            if let popoverController = alertController.popoverPresentationController{
                popoverController.sourceView = vc.view
                var frame = chromeCastButton.frame
                if self.presentVC is PageViewController{
                    frame.origin.y = frame.origin.y + 15
                    frame.origin.x = vc.view.frame.width - 35
                    var barbuttonItem:UIBarButtonItem?
                    if self.presentVC.navigationItem.rightBarButtonItems?.isEmpty == false{
                        for barbuttons:UIBarButtonItem in self.presentVC.navigationItem.rightBarButtonItems!{
                            if barbuttons.customView is UIButton{
                                barbuttonItem = barbuttons
                                break
                            }
                        }
                        if barbuttonItem != nil{
                            popoverController.sourceView = barbuttonItem!.customView
                            popoverController.sourceRect = CGRect(x:(barbuttonItem?.customView?.bounds.size.width)!*0.45,y:(barbuttonItem?.customView?.bounds.size.height)!*0.75, width:0,height:0)
                        }
                        else{
                            popoverController.sourceRect =  frame
                        }
                    }
                    else{
                        popoverController.sourceRect =  frame
                    }
                }
                else{
                    popoverController.sourceRect =  frame
                }
                popoverController.permittedArrowDirections = .up
                
            }
        }
    }
    
    func updateAlertFramesOnOrientation(chromeCastButton: UIButton, view: UIView)  {
        if(alertController != nil){
            if let popoverController = alertController.popoverPresentationController{
                popoverController.sourceView = view
                var frame = chromeCastButton.frame
                if self.presentVC is PageViewController{
                    //frame.origin.y = frame.origin.y + 15
                    frame.origin.x = view.frame.width - 35
                    
                }

                popoverController.sourceRect = frame
                popoverController.permittedArrowDirections = .up
            }
        }
    }
    
    func chooseDevice(chromeCastButton: UIButton, vc: UIViewController) {
        btnImage = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_NORMAL)
        btnImageSelected = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_CONNECTED)
        
        self.chromecastButton = chromeCastButton
        self.presentVC = vc
        self.listOfAvailableDevices.removeAll()
        self.listOfAvailableDevices = SecondScreenDeviceProvider.shared.allAvailableDevices()
        
        if self.selectedDevice == nil {
            
            alertController = UIAlertController(title: nil, message: "Connect To Cast", preferredStyle: .actionSheet)
            self.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, vc: self.presentVC)
            if self.listOfAvailableDevices.count == 0{
                alertController.message = "No Device Available"

            }
            for selectedDevice in self.listOfAvailableDevices {
                let deviceSelected = selectedDevice as! GCKDevice
                
                alertController.addAction(UIAlertAction(title: deviceSelected.friendlyName, style: .default, handler: { alertAction in
                    self.selectedDevice = deviceSelected
                    self.connectToDevice()
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { AlertAction in
                self.alertController.dismiss(animated: true, completion: nil)
            }))
            
            
            presentVC.present(alertController, animated: true, completion: { () -> Void in
                
            })
        }
        else {
            if self.isConnected() {
                alertController = UIAlertController(title: nil, message: "Connected To: \(selectedDevice.friendlyName ?? "")", preferredStyle: .actionSheet)
                self.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, vc: self.presentVC)

                
                let addDisconnectingAction = UIAlertAction(title: "Disconnect device", style: .destructive, handler: { alertAction in
                    
                    self.deviceDisconnected()
                    self.updateButtonStates()
                    self.alertController.dismiss(animated: true, completion: nil)
                    
                })
                
                let addCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alertAction in
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                })
                
                // Add action to the controller
                alertController.addAction(addDisconnectingAction)
                alertController.addAction(addCancelAction)
                
                presentVC.present(alertController, animated: true, completion: nil)
            }
            else {
                alertController = UIAlertController(title: nil, message: "Connecting To: \(selectedDevice.friendlyName ?? "")", preferredStyle: .actionSheet)
                self.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, vc: self.presentVC)


                let addCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alertAction in
                    
                    self.alertController.dismiss(animated: true, completion: nil)
                })
                
                // Add action to the controller
                alertController.addAction(addCancelAction)
                
                presentVC.present(alertController, animated: true, completion: nil)
            }
           
        }
    }
    
    
    /** func isConnected - will return true if App is connected to casting device.
     */
    
    func isConnected() -> Bool {
        
        return (self.deviceManager != nil) && self.deviceManager.connectionState == GCKConnectionState.connected
    }
    
    /** func isConnected - will return true if App is connected to casting device.
     */
    
    
    
    
    /** func connectToDevice - will connect to selected device.
     
     */
    
    func connectToDevice() {
        if self.selectedDevice != nil{
            self.deviceManager = GCKDeviceManager(device: self.selectedDevice, clientPackageName:"CFBundleIdentifier")
            self.deviceManager.delegate = self
            self.deviceManager.connect()
            self.animateChromeCastButton()
        }

    }
    
    func deviceDisconnected() {
        if GCKCastContext.sharedInstance().sessionManager.currentCastSession != nil {
            GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.remove(CastController())
            GCKCastContext.sharedInstance().sessionManager.endSessionAndStopCasting(true)
        }
        else{
            let castOptions = GCKCastOptions(receiverApplicationID: kGCKMediaDefaultReceiverApplicationID)
            let session : GCKCastSession = GCKCastSession.init(device: self.selectedDevice, sessionID: self.sessionId, castOptions: castOptions)
            session.remoteMediaClient?.remove(CastController())
            if session.sessionID != nil {
                self.deviceManager.stopApplication(withSessionID: session.sessionID!)
            }
        }

        GCKCastContext.sharedInstance().sessionManager.remove(self)
        if self.selectedDevice != nil && self.deviceManager != nil {
            
            self.deviceManager.leaveApplication()
            if self.sessionId != nil {
                self.deviceManager.stopApplication(withSessionID: self.sessionId!)
            }
            
            self.deviceManager!.disconnect()
//            self.deviceManager.stopApplication()
        }
        self.setVideoContent(contentId: "", filmTitle: "", durationSeconds: 0)
        self.deviceManager = nil
        self.selectedDevice = nil
        self.stopAnimatingChromecastButton()
        self.updateButtonStates()
        if delegate != nil {
            
            if (delegate?.responds(to: #selector(CastPopOverViewDelegate.didDisConnectToCastDevice)))! {
                
                delegate?.didDisConnectToCastDevice!()
            }
        }
        
    }
    
    
    
    func animateChromeCastButton()
    {
        if self.chromecastButton != nil {
            self.chromecastButton.imageView!.animationImages =
                [ UIImage(named:Constants.IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE1)!,  UIImage(named:Constants.IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE2)!,
                  UIImage(named:Constants.IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE3)!,  UIImage(named:Constants.IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE1)! ]
            self.chromecastButton.imageView!.animationDuration = 2
            self.chromecastButton.imageView!.startAnimating()
        }
    }
    
    func stopAnimatingChromecastButton()
    {
        if self.chromecastButton != nil{
            if self.chromecastButton.imageView != nil {

                if self.chromecastButton.imageView!.isAnimating {

                    self.chromecastButton.imageView!.stopAnimating()
                }
            }

            if (self.deviceManager != nil) {
                if self.deviceManager.connectionState == GCKConnectionState.connected {
                    chromecastButton.setImage(btnImageSelected, for: UIControlState.normal)
                }
            }
            else {
                chromecastButton.setImage(btnImage, for: UIControlState.normal)
            }
        }

    }
    
    
    /** func updateButtonStates - Update chromecast Icon Hidden state for availble devices and and Image for connected or Disconnected State.
     
     */
    
    
    func updateButtonStates() {
        if chromecastButton != nil{
            if (self.listOfAvailableDevices.count == 0) {
                chromecastButton.setImage(btnImage, for: UIControlState.normal)
                chromecastButton.isHidden = false
            }
            else {
                chromecastButton.setImage(btnImage, for: UIControlState.normal)
                chromecastButton.isHidden = false
                if self.isConnected() {
                    chromecastButton.setImage(btnImageSelected, for: UIControlState.normal)
                }
                else {
                    chromecastButton.setImage(btnImage, for: UIControlState.normal)
                }
            }
            
        }
    }
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if self.isConnected() {
            if buttonIndex < self.listOfAvailableDevices.count {
                self.selectedDevice = self.listOfAvailableDevices[buttonIndex] as! GCKDevice
                NSLog("Selecting device: \(String(describing: self.selectedDevice.friendlyName))")
                self.connectToDevice()
            }
        }
        else {
            if buttonIndex == 1 {
                
                self.deviceDisconnected()
                self.updateButtonStates()
            }
            else if buttonIndex == 0 {
            }
        }
    }
    
    
    
    /*
     GCKSessionManager delegate
     */
    
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        print("")
        CastController().updateCastProgress()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        print("")
        self.deviceDisconnected()
        //self.switchToLocalPlayback()
    }
    
    
    /*
     GCKDeviceManager delegate
     */
    
    func deviceManagerDidConnect(_ deviceManager: GCKDeviceManager) {
        NSLog("Connected!")
        GCKCastContext.sharedInstance().sessionManager.startSession(with: self.selectedDevice)
        GCKCastContext.sharedInstance().sessionManager.add(self as GCKSessionManagerListener)
        self.stopAnimatingChromecastButton()
        self.updateButtonStates()
        self.deviceManager.launchApplication(kGCKMediaDefaultReceiverApplicationID)
        
    }
    
    func deviceManager(_ deviceManager: GCKDeviceManager, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata, sessionID: String, launchedApplication: Bool) {
        NSLog("application has launched \(launchedApplication)")
        self.sessionId = sessionID
        let mediaInfo :GCKMediaInformation? = (GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.mediaInformation)
        if (mediaInfo != nil) && ((mediaInfo?.customData) is String){
            if let currentContentId = mediaInfo?.customData  as? String{
                self.setVideoContent(contentId: currentContentId, filmTitle: mediaInfo?.metadata?.string(forKey: kGCKMetadataKeyTitle), durationSeconds: mediaInfo?.streamDuration)

            }
        }
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name("ApplicationResumeCasting"), object: nil)
        if delegate != nil && (delegate?.responds(to: #selector(CastPopOverViewDelegate.didConnectToCastDevice)))! {
            
            delegate?.didConnectToCastDevice!()
        }
    }
    
    func deviceManager(_ deviceManager: GCKDeviceManager, didFailToConnectToApplicationWithError error: Error) {
        self.showError(error: error as NSError)
        
        self.deviceDisconnected()
        
    }
    
    func deviceManager(_ deviceManager: GCKDeviceManager, didFailToConnectWithError error: Error) {
        self.showError(error: error as NSError)
        
        self.deviceDisconnected()
        
    }
    
    func deviceManager(_ deviceManager: GCKDeviceManager, didDisconnectWithError error: Error?) {
        NSLog("Received notification that device disconnected")
        
        if error != nil {
            self.showError(error: error! as NSError)
        }
        
        self.deviceDisconnected()
        
    }
    
    func showError(error: NSError) {
        let alert = UIAlertController(title: "Something went wrong", message: error.description, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        presentVC.present(alert, animated: true, completion: nil)
    }
    
    
    func  setVideoContent(contentId: String?, filmTitle:String?, durationSeconds: Double? ) {
        if contentId != nil {
            videoObject.videoContentId = contentId!
        }
        if filmTitle != nil {
            videoObject.videoTitle = filmTitle!
        }
        if durationSeconds != nil {
            videoObject.videoPlayerDuration = durationSeconds!
        }
    }
    func getVideoContent() -> VideoObject! {
        return self.videoObject
    }
    
    
    
    
}


