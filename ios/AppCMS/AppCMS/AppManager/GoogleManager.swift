//
//  GoogleManager.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class GoogleManager: NSObject, GIDSignInDelegate {

    static let sharedInstance = GoogleManager()
    
    var loginViewController:LoginViewController?
    var googleLoginDoneHandler: ((Bool, String?, String?, String?, String?) -> Void)? = nil
    
    func loginWithGoogle(googleLoginDone: @escaping ((_ loginStatus: Bool, _ googleAccessToken: String?, _ name: String?, _ email: String?, _ googleID: String?) -> Void), viewController: UIViewController)
    {
        let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
        
        guard let googleClientId:String = dicRoot["GoogleClientId"] as? String else { return googleLoginDone(false, nil, nil, nil, nil) }
        
        if #available(iOS 9.0, *) {
            
        }
        else {
            
            //Added check for iOS 8 and below as Google sign in was throwing oauth error.
            let dictionaty = NSDictionary(object: "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forKey: "UserAgent" as NSCopying)
            UserDefaults.standard.register(defaults: dictionaty as! [String : Any])
        }
        
        GIDSignIn.sharedInstance().clientID = googleClientId
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().signIn()
        loginViewController = viewController as? LoginViewController
        
        googleLoginDoneHandler = googleLoginDone
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            
            if googleLoginDoneHandler != nil {
                
                googleLoginDoneHandler!(false, nil, nil, nil, nil)
            }
        }
        else {
            
            if (user.authentication != nil) {
                
                googleLoginDoneHandler!(true, user?.authentication.idToken, user?.profile.name, user?.profile.email, user?.authentication.clientID)
            }
            else {
                
                googleLoginDoneHandler!(false, nil, nil, nil, nil)
            }
        }
    }
}
