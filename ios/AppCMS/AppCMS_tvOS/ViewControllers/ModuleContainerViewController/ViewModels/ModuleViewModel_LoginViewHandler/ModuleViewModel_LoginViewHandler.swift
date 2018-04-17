//
//  ModuleViewModel_LoginViewHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_LoginViewHandler: ModuleViewModel, LoginViewDelegate {
    
    func getLoginView(parentViewFrame:CGRect, loginObject: LoginViewObject_tvOS) -> LoginView_tvOS {
        
        let moduleHeight = CGFloat(Utility.fetchLoginViewLayoutDetails(loginViewObject: loginObject).height ?? 880)
        let moduleWidth = CGFloat(Utility.fetchLoginViewLayoutDetails(loginViewObject: loginObject).width ?? 1920)
        let loginView : LoginView_tvOS = LoginView_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), loginObject: loginObject, viewTag: 1,relativeFrame: parentViewFrame)
        loginView.delegate = self

        return loginView
    }
    
    
    func showAlert(_ title : String, _ messgae : String) -> UIAlertController {
        let tempAlertController = UIAlertController(title: title, message: messgae, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        tempAlertController.addAction(defaultAction)
        
        return tempAlertController
    }
    
    
   //MARK: - LoginView Delegate
    
    func showAlertControllerForError(title: String, message: String) {
       let alertController =  showAlert(title, message)
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.showAlertController(alertController:))))! {
            delegate?.showAlertController!(alertController: alertController)
        }
        
    }
    
    func userLoginDone() {

        if let appContainer = Constants.kAPPDELEGATE.appContainerVC {
            if appContainer.isSubContainerDisplayedModally! {
                ///User successfull login dismiss subContainer
                appContainer.dismissSubContainer()
                Constants.kNOTIFICATIONCENTER.post(name: Constants.kUpdateNavigationMenuItems, object: nil)
            } else {
                ///User successfull login dismiss subContainer
                appContainer.dismissSubContainer()
                ///User successfull login navigate to home page
                Constants.kAPPDELEGATE.navigateToHomeScreen()
            }
        } else {
            ///User successfull login navigate to home page
            Constants.kAPPDELEGATE.navigateToHomeScreen()
        }
    }
    
    func forgotPasswordTapped() {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.forgotPasswordButtonTapped)))! {
            ///Create forgot password screen and load it.
            
            if let forgotVC = getLayoutForTheForgotScreen()
            {
                delegate?.forgotPasswordButtonTapped!(forgotCredentialVC: forgotVC)
            }
        }
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
    
    
    //MARK:Collection Grid Delegates and Carousel Delegate
    func getLayoutForTheForgotScreen() -> ModuleContainerViewController_tvOS? {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Reset Password") ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            viewControllerPage?.pageName = "Forgot Password"
            let forgotModuleVC:ModuleContainerViewController_tvOS = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "reset_password")
            forgotModuleVC.addBackgroundImage = true
            return forgotModuleVC;
        }
        return nil
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
    
    func cancelButtonTapped() {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.popCurrentViewController)))! {
            ///Create forgot password screen and load it.
            delegate?.popCurrentViewController!()
        }
    }
    
    func resetPasswordTapped() {
        
    }
}
