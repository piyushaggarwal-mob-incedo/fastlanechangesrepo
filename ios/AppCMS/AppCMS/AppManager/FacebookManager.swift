//
//  FacebookManager.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 29/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin

class FacebookManager: NSObject {
    
    class func loginWithFacebook(facebookLoginDone: @escaping ((_ loginStatus: Bool, _ fbAccessToken: String, _ name: String?, _ email: String?, _ fbID: String?) -> Void), viewController: UIViewController)
    {
        let fbLoginManager: LoginManager = LoginManager()
        if AccessToken.current != nil {
            fbLoginManager.logOut()
            return
        }
        
        fbLoginManager.logIn(readPermissions: [.email, .publicProfile, .userFriends], viewController: viewController) { (loginResult: LoginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermission, let declinedPermission, let accessToken):
                if grantedPermission.count == 3
                {
                    getFBUserDetails(loginDetails: { (name, email, facebookID) in
                        facebookLoginDone(true, accessToken.authenticationToken, name, email, facebookID)
                    })
                }
                print(declinedPermission.count)
            }
        }
//        fbLoginManager.logIn([.email, .publicProfile, .userFriends], viewController: viewController) { (loginResult: LoginResult) in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermission, let declinedPermission, let accessToken):
//                if grantedPermission.count == 3
//                {
//                    getFBUserDetails(loginDetails: { (name, email, facebookID) in
//                        facebookLoginDone(true, accessToken.authenticationToken, name, email, facebookID)
//                    })
//                }
//                print(declinedPermission.count)
//            }
//        }

    }
    
    class func getFBUserDetails(loginDetails: @escaping ((_ name: String?, _ email: String?, _ fbID: String?) -> Void)) -> Void {
        let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.GET, apiVersion: GraphAPIVersion.defaultVersion)
        graphRequest.start { (connection, result) in
            switch result
            {
            case .success(let graphResponse):
            if let responseDictionary = graphResponse.dictionaryValue
            {
                print(responseDictionary)
                let name = responseDictionary["name"] as? String
                let socialIdFB = responseDictionary["id"] as? String
                let email = responseDictionary["email"] as? String
                loginDetails(name, email, socialIdFB)
            }
                    break
                    
            case .failed(let error):
                print(error)
    
                break
            }
        }
    }
}
