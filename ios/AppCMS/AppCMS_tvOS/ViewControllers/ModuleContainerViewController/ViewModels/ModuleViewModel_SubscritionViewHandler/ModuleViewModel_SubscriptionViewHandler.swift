
import UIKit

class ModuleViewModel_SubscriptionViewHandler:  ModuleViewModel, SubscriptionViewDelegate {
    deinit {
        ///release any strong refrence object or observers
    }
    
    
    
    /// Call this method to create Setting View.
    ///
    /// - Parameters:
    /// - parentViewFrame: CGRect object
    /// - settingObject: SettingViewObject_tvOS object
    /// - Return:
    /// - SettingView object
    func getSubscriptionView(parentViewFrame:CGRect, subscriptionObject: SubscriptionViewObject_tvOS) -> SubscriptionView_tvOS {
        
        let moduleHeight = CGFloat(Utility.fetchSubscriptionViewLayoutDetails(SubscriptionViewObject: subscriptionObject).height ?? 1100)
        let moduleWidth = CGFloat(Utility.fetchSubscriptionViewLayoutDetails(SubscriptionViewObject: subscriptionObject).width ?? 1920)
        let SubscriptionView  = SubscriptionView_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), subscriptionObject: subscriptionObject, viewTag: 1,relativeFrame: parentViewFrame)
        SubscriptionView.delegate = self
        return SubscriptionView
    }
    
    func loadAncillaryPage(_ Type: String) {
        
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.loadAncillaryPageData(ancillaryVC:))))! {
            
            ///Create ancillary password screen and load it.
            if let ancillaryVC = getLayoutOfTheAncillaryPage(Type)
            {
                delegate?.loadAncillaryPageData!(ancillaryVC: ancillaryVC)
            }
        }
        
    }
    
    func getLayoutOfTheAncillaryPage(_ pageName : String) -> ModuleContainerViewController_tvOS? {
        
        let pageUpdated = Page.init(pageString: Constants.kSTRING_PAGETYPE_MODULAR)
        pageUpdated.pageName = pageName
        pageUpdated.pageAPI = ""
        pageUpdated.pageUI = ""
        pageUpdated.pageId = "123"
        
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Privacy Policy") ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        if viewControllerPage != nil {
            pageUpdated.modules = (viewControllerPage?.modules)!
            let ancillaryPage = ModuleContainerViewController_tvOS.init(pageObject: pageUpdated, pageDisplayName:pageName)
            ancillaryPage.pagePath = pageName == "Terms" ? "/tos" : "/privacy-policy"
            ancillaryPage.addBackgroundImage = true
            return ancillaryPage
        }
        return nil
    }
    
    func loadCreateAccountPage(shouldDismiss: Bool) {
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            if shouldDismiss {
                Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadSignUpPage,{ [weak self] () in
                    guard let checkedSelf = self else {return}
                    checkedSelf.userLoginDone()
                })
            } else {
                Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadSignUpPage)
            }
        }
    }
    
    func userLoginDone() {
        
        if let appContainer = Constants.kAPPDELEGATE.appContainerVC {
            if appContainer.isSubContainerDisplayedModally! {
                ///User successfull login dismiss subContainer
                appContainer.dismissSubContainer()
                Constants.kNOTIFICATIONCENTER.post(name: Constants.kUpdateNavigationMenuItems, object: nil)
            } else {
                appContainer.dismissSubContainer()
                ///User successfull login navigate to home page
                Constants.kAPPDELEGATE.navigateToHomeScreen()
            }
        } else {
            ///User successfull login navigate to home page
            Constants.kAPPDELEGATE.navigateToHomeScreen()
        }
    }
    
    func loadHomePage(){
        if let appContainer = Constants.kAPPDELEGATE.appContainerVC {
            if appContainer.isSubContainerDisplayedModally! {
                appContainer.dismissSubContainer()
                Constants.kNOTIFICATIONCENTER.post(name: Constants.kUpdateNavigationMenuItems, object: nil)
            } else {
                appContainer.dismissSubContainer()
                Constants.kAPPDELEGATE.navigateToHomeScreen()
            }
        } else {
            Constants.kAPPDELEGATE.navigateToHomeScreen()
        }

    }
    
}
