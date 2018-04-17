//
//  ModuleViewModel_AncillaryViewHandler.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_AncillaryViewHandler: ModuleViewModel {
    
    var ancillaryView : AncillaryView_tvOS?
    var pageAPIData : PageAPIObject?
    
    ///Keep refrence of type of  page loading i.e. TOS , Privacy Policy etc.
    var pageType : String?
    
    ///Keep reference whether to pick cache page api or not
    var shouldUseCacheUrl: Bool?
    
    /// Network unavailable alert.
    private var networkUnavailableAlert:UIAlertController?
    
    /// Holds the network status of the device.
    private let networkStatus = NetworkStatus.sharedInstance
    
    
    deinit {
        /// remove observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    
    /**
     getAncillaryView is used for creating all type of ancillary view i.e. TOS, Privacy Policy etc. This type of view is identified by RichText.
     - parameter parentViewFrame: contains frame of the view.
     - parameter ancillaryObject: contains AncillaryViewObject_tvOS instance which is used for provide view information.
     - returns: ancillaryView.
     */
    func getAncillaryView(parentViewFrame:CGRect, ancillaryObject: AncillaryViewObject_tvOS) -> AncillaryView_tvOS {
        
        let moduleHeight = CGFloat(Utility.fetchAncillaryViewLayoutDetails(ancillaryViewObject: ancillaryObject).height ?? 880)
        let moduleWidth = CGFloat(Utility.fetchAncillaryViewLayoutDetails(ancillaryViewObject: ancillaryObject).width ?? 1920)
        ancillaryView  = AncillaryView_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), ancillaryObject: ancillaryObject )
        
        NotificationCenter.default.addObserver(self, selector:#selector(ModuleViewModel_AncillaryViewHandler.checkNetworkStatusAndCallAPI), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        
        return ancillaryView!
    }
    
    
    @objc private func checkNetworkStatusAndCallAPI()
    {
        if networkStatus.isNetworkAvailable() && pageAPIData == nil {
            fetchHtmlContent()
        }
        else{
            if pageAPIData == nil{
                showAlert()
            }
        }
    }
    
    
    /**
     Create AlertController and display alert controller with close and retry option.
     */
    private func showAlert() {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { [weak self] (result : UIAlertAction) in
            self?.ancillaryView?.showEmptyLabelOnAncillaryView()
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { [weak self] (result : UIAlertAction)  in
            
            self?.checkNetworkStatusAndCallAPI()
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        alertTitleString = Constants.kInternetConnection
        alertMessage = Constants.kInternetConntectionRefresh
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction,retryAction])
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.showAlertController(alertController:))))! {
            delegate?.showAlertController!(alertController:networkUnavailableAlert!)
        }
    }
    
    
    func loadAncillaryPageData(){
        checkNetworkStatusAndCallAPI()
    }
    
    /**
     fetch ancillary page data html data. Ancillary page html url endpoint depend's on the type of ancillary page is being displayed.
     */
    private func fetchHtmlContent()
    {
        self.ancillaryView?.removeEmptyMessageLbl()
        self.ancillaryView?.addActivityIndicator()
        DispatchQueue.global(qos: .userInitiated).async {
            
            var apiEndPoint:String = "/content/pages?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
            
            apiEndPoint = "\(apiEndPoint)&path=\(self.pageType!)"
            //                apiEndPoint = "https://prod-api.viewlift.com/content/pages?site=snagfilms&includeContent=true&path=\(self._pageType!)"///tos"
            
            DataManger.sharedInstance.fetchContentForAncillaryPage(shouldUseCacheUrl: self.shouldUseCacheUrl ?? false, apiEndPoint: apiEndPoint) { [weak self] (pageAPIObjectResponse) in
                DispatchQueue.main.async {
                    self?.ancillaryView?.removeActivityIndicator()
                    
                    if pageAPIObjectResponse != nil{
                        
                        ///Get the separator view and unhide it.
                        (self?.ancillaryView?.view.viewWithTag(301) as? SFSeparatorView)?.isHidden = false
                        
                        
                        ///Set the title of ancillary page that is being displayed.
                        if let titleValue = pageAPIObjectResponse?.value(forKey: "pageTitle") as? String{
                            (self?.ancillaryView?.view.viewWithTag(201) as? UILabel)?.text = titleValue.uppercased()
                        }
                        
                        
                        ///Get the  textView from the view using viewWithTag func, also fetch rawtext from textmodule and
                        ///map it to text view.
                        if pageAPIObjectResponse?.pageModules != nil{
                            self?.pageAPIData = pageAPIObjectResponse
                            for pageContent in (pageAPIObjectResponse?.pageModules?.values)! {
                                if (pageContent as? SFModuleObject)?.moduleType == "TextModule"
                                {
                                    //                                        print((pageContent as? SFModuleObject)?.moduleRawText ?? "")
                                    let textView = self?.ancillaryView?.view.viewWithTag(101) as? UITextView
                                    
                                    if let rawText = (pageContent as? SFModuleObject)?.moduleRawText
                                    {
                                        do {
                                            let data = rawText.data(using: String.Encoding.unicode, allowLossyConversion: true)
                                            if let d = data {
                                                let htmlStr = try NSAttributedString(data: d,
                                                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                                 documentAttributes: nil)
                                                textView?.text = htmlStr.string
                                            }
                                            var fontFamily:String?
                                            if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
                                                fontFamily = _fontFamily
                                            }
                                            if fontFamily == nil {
                                                fontFamily = "OpenSans"
                                            }
                                            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports.uppercased(){
                                                textView?.font = UIFont(name: "\(fontFamily!)", size: 26.0)
                                            }
                                            else{
                                                textView?.font = UIFont(name: fontFamily!, size: 23.0)
                                            }
                                            textView?.textColor = UIColor.white

                                            DispatchQueue.main.async {
                                                if let unwrappedSelf = self {
                                                    if let textView = textView {
                                                        if unwrappedSelf.checkIfTextViewIsScrollable(textView) {
                                                            unwrappedSelf.ancillaryView?.showTheUpDownButtons()
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        catch{
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                    }
//                    else{
//                        self?.ancillaryView?.showEmptyLabelOnAncillaryView()
//                    }
                }
            }
        }
    }
    
    private func checkIfTextViewIsScrollable(_ textView: UITextView) -> Bool {
        var isScrollable = false
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.layoutIfNeeded()
        if newSize.height > textView.bounds.height {
            isScrollable = true
        }
        return isScrollable
    }
    
    
    func showEmptyLabel(){
        if networkUnavailableAlert != nil && networkStatus.isNetworkAvailable() {
            networkUnavailableAlert?.dismiss(animated: true, completion: {
            })
        }
        
        
    }
}
