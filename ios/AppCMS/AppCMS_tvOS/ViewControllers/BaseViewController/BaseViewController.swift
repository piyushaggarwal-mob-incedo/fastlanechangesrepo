//
//  BaseViewController.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 24/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit


/// Alert Type
///
/// - AlertTypeNoInternetFound: Use this when the internet is not found.
/// - AlertTypeNoResponseReceived: Use this when no response is received.
enum AlertType {
    case AlertTypeNoInternetFound
    case AlertTypeNoResponseReceived
}

/// Acts as the Base View Controller class.
class BaseViewController: UIViewController {
    
    /// Progress Indicator instance.
    private var progressIndicator:UIActivityIndicatorView?
    /// Network unavailable alert.
    private var networkUnavailableAlert:UIAlertController?
    /// Holds the network status of the device.
    private let networkStatus = NetworkStatus.sharedInstance
    
    ///Displays empty message label
    private var emptyMessageLbl : UILabel?
    
    func loadPageData() {

        if networkUnavailableAlert != nil && networkStatus.isNetworkAvailable() {
            networkUnavailableAlert?.dismiss(animated: true, completion: {
            })
        }
    }
    
    func showEmptyLabel(){
        if networkUnavailableAlert != nil && networkStatus.isNetworkAvailable() {
            networkUnavailableAlert?.dismiss(animated: true, completion: {
            })
        }
    }
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(BaseViewController.loadPageData), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        loadPageData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideActivityIndicator()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType, alertTitle:String?, alertMessage:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { [weak self] (result : UIAlertAction) in
            self?.showEmptyLabel()
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            self.loadPageData()
        }
        
        var alertTitleString:String = alertTitle ?? "No Response Received"
        var alertMessage:String = alertMessage ?? "Unable to fetch data!\nDo you wish to Try Again?"
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: alertMessage, alertActions: [closeAction,retryAction])
        self.present(networkUnavailableAlert!, animated: true, completion: {
        })
    }
    
    func showActivityIndicator() {
        
        if progressIndicator == nil {
            progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        if self.isShowing() {
            self.progressIndicator?.showIndicatorOnWindow()
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func hideActivityIndicator() {
        progressIndicator?.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
    
    func failureCaseReceivedCheckAndShowAlert(alertTitle:String?, alertMessage:String?) {
        hideActivityIndicator()
        if networkStatus.isNetworkAvailable() {
            showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, alertTitle: alertTitle, alertMessage: alertMessage)
        } else {
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertTitle: alertTitle, alertMessage: alertMessage)
        }
    }
    
    func isDeviceConnectedToInternet() -> Bool {
        return networkStatus.isNetworkAvailable()
    }
    
    /* getEmptyMessageLbl method is used for creating label and displaying message in absense of network and data is not available to display.*/
    func getEmptyMessageLbl() -> UILabel{
        emptyMessageLbl = UILabel.init(frame: CGRect(x: 0, y: 0, width: 900, height: 100))
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        emptyMessageLbl?.font = UIFont(name: "\(fontFamily!)-Semibold", size: 28)
        emptyMessageLbl?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")//UIColor.white
        emptyMessageLbl?.textAlignment = .center
        emptyMessageLbl?.numberOfLines = 0
        emptyMessageLbl?.text = Constants.kInternetConntectionRefresh
        return emptyMessageLbl!
    }
    
    /*removeEmptyMessageLbl method is used for removing label from view if label is displaying*/
    func removeEmptyMessageLbl(){
        emptyMessageLbl?.removeFromSuperview()
    }

}
