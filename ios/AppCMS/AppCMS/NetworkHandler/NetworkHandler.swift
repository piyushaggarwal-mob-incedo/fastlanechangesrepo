//
//  NetworkHandler.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 07/03/17.
//  Copyright © 2017 Abhinav Saldi. All rights reserved.
//

import Foundation
import Alamofire
import AdSupport

class NetworkHandler: NSObject {
    
    static let sharedInstance:NetworkHandler = {
        
        let instance = NetworkHandler()
        
        return instance
    }()

    let utilityQueue = DispatchQueue.global(qos: .utility)

    func callNetworkForConfiguration(apiURL:String, responseForConfiguration: @escaping ( (_ responseConfigData: Data?, _ isSuccess:Bool) -> Void)) -> Void {
        
        Alamofire.request(apiURL).validate().responseJSON { response in
            switch response.result{
            case .success:
                let configData = response.data
                
                if configData != nil {
                    responseForConfiguration(configData!, true)
                }
                else {
                    
                    responseForConfiguration(nil, false)
                }
                print ("response: " + (response.data?.description)!)
            case .failure:
                responseForConfiguration(nil, false)
                print("Error: ")
                
            }
        }
    }
    
    
    //MARK: Method to trigger floodlight api request
    func floodLightAPICallWithSuccess(success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        let randomNumber = Int(arc4random())
        let requestString = "https://ad.doubleclick.net/ddm/activity/src=6070801;cat=appco0;type=msnbm0;dc_rdid=\(ASIdentifierManager.shared().advertisingIdentifier.uuidString);dc_lat=;tag_for_child_directed_treatment=;ord=\(randomNumber)ld"
        
        Alamofire.request(requestString).validate().responseJSON { response in
            switch response.result{
            case .success:
                success(true)
                print ("response: " + (response.data?.description)!)
            case .failure:
                success(true)
            }
        }
    }
    
 
    func callNetworkForContentFetch(apiURL:String, requestType:HTTPMethod, requestHeaders:HTTPHeaders?,requestParameter:Parameters?,responseForConfiguration: @escaping ( (_ responseConfigData: Data?, _ isSuccess:Bool) -> Void)) -> Void {
        
        var encodedURL: String;
        
        //Once utility class will be added to tvos target update below if else. 
        #if os(iOS)
            encodedURL = Utility.urlEncodedString_ch(emailStr: apiURL)
        #else
            encodedURL = self.urlEncodedString_ch(emailStr: apiURL)
        #endif
        
        var requestHeaders:HTTPHeaders? = requestHeaders
        
        if requestHeaders == nil {
            
            requestHeaders = [:]
        }
        
        requestHeaders?["x-api-key"] = AppConfiguration.sharedAppConfiguration.apiSecretKey ?? ""
        requestHeaders?["Content-Type"] = "application/json"
        requestHeaders?["Accept"] = "application/json"
        requestHeaders?["Accept-Encoding"] = "gzip"

        Alamofire.request(URL(string:encodedURL)!, method: requestType, parameters: requestParameter, encoding: JSONEncoding.default, headers: requestHeaders).validate().responseJSON { response in
            
            switch response.result{
            case .success:
                let configData = response.data
                
                if configData != nil {
                    responseForConfiguration(configData!, true)
                }
                else
                {
                    responseForConfiguration(nil, false)
                }
            case .failure:
                
                let errorData = response.data
                
                if errorData != nil {
                    
                    responseForConfiguration(errorData!, false)
                }
                else  {
                    
                    responseForConfiguration(nil, false)
                }                
            }
        }
    }
    
    
    func callNetworkForSearchResults(apiURL:String, requestHeaders:HTTPHeaders?, responseForConfiguration: @escaping ( (_ responseConfigData: Data?, _ isSuccess:Bool) -> Void)) -> Void {
        
        var encodedURL: String;
        
        //Once utility class will be added to tvos target update below if else.
        #if os(iOS)
            encodedURL = Utility.urlEncodedString_ch(emailStr: apiURL)
        #else
            encodedURL = self.urlEncodedString_ch(emailStr: apiURL)
        #endif
        
        //Cancelling previous search request
        let sessionManager = Alamofire.SessionManager.default
        
        sessionManager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            
            dataTasks.forEach({task in
                
                task.cancel()
            })
        }
        
        var requestHeaders:HTTPHeaders? = requestHeaders
        
        if requestHeaders == nil {
            
            requestHeaders = [:]
        }
        
        requestHeaders?["x-api-key"] = AppConfiguration.sharedAppConfiguration.apiSecretKey ?? ""
        requestHeaders?["Content-Type"] = "application/json"
        requestHeaders?["Accept"] = "application/json"
        requestHeaders?["Accept-Encoding"] = "gzip"

        Alamofire.request(URL(string:encodedURL)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: requestHeaders).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                let configData = response.data
                
                if configData != nil {
                    responseForConfiguration(configData!, true)
                }
                else
                {
                    responseForConfiguration(nil, false)
                }
            case .failure:
                
                let errorData = response.data
                
                if errorData != nil {
                    
                    responseForConfiguration(errorData!, false)
                }
                else  {
                    
                    responseForConfiguration(nil, false)
                }
            }
        }
    }
    
    
    func callNetworkToPostBeaconData(apiURL:String, requestHeaders:HTTPHeaders?,parameters : Array<Dictionary<String,String>>, responseForConfiguration: @escaping ( (_ responseConfigData: Bool?) -> Void)) -> Void {
        var encodedURL: String;
        
        //Once utility class will be added to tvos target update below if else.
        #if os(iOS)
            encodedURL = Utility.urlEncodedString_ch(emailStr: apiURL)
        #else
            encodedURL = self.urlEncodedString_ch(emailStr: apiURL)
        #endif
        var requestHeaders:HTTPHeaders? = requestHeaders
        
        if requestHeaders == nil {
            
            requestHeaders = [:]
        }
        
      //  [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        requestHeaders?["x-api-key"] = AppConfiguration.sharedAppConfiguration.apiSecretKey ?? ""
        requestHeaders?["Content-Type"] = "application/json"
        
        guard let requestUrl = URL(string:encodedURL) else { return responseForConfiguration(false) }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields=requestHeaders
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        #if os(iOS)
            let userAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")!
            request.setValue(userAgent, forHTTPHeaderField:"User-Agent")
        #endif
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                let queueResultJson = try? JSONSerialization.jsonObject(with: data!)
                                if queueResultJson is Dictionary<String,AnyObject> {
                                    let queueResultDict:Dictionary<String,AnyObject>? = queueResultJson as? Dictionary<String,AnyObject>
                                    if queueResultDict != nil {
                                        if let val = queueResultDict?["RequestResponses"] {
                                            if (val.objectAt(0)["RecordId"] != nil) {
                                                responseForConfiguration(true)
                                            } else {
                                                responseForConfiguration(false)
                                            }
                                        }
                                    }
                }
                print(usableData)
            }
            else {
                responseForConfiguration(false)
            }
        }
        task.resume()
    }
    
    // FIXME: Method is already added in Utility as utility is not added as target for tvos method created in self
    //remove it once utility class is generalised for the same
    func urlEncodedString_ch(emailStr: String) -> String {
        
        let output = NSMutableString()
        guard let source = emailStr.cString(using: String.Encoding.utf8) else {
            return emailStr
        }
        let sourceLen = source.count
        
        var i = 0
        while i < sourceLen - 1 {
            let thisChar = source[i]
            if thisChar == 32 {
                output.append("+")
            }
            else {
                output.appendFormat("%c", thisChar)
            }
            i += 1
        }
        return output as String
    }
    
    
    #if os(iOS)
    func callNetworkForUrbanAirship(apiURL:String, requestParameter:Parameters?, requestType:HTTPMethod,responseForConfiguration: @escaping ( (_ responseConfigData: Data?, _ isSuccess:Bool) -> Void)) -> Void {
        
        let authenticationValue = encodeAuthorizationForUrbanAirship() ?? ""
        let requestHeaders = ["Accept":"application/vnd.urbanairship+json; version=3;", "Content-Type":"application/json","Authorization":authenticationValue]
        
        Alamofire.request(URL(string:apiURL)!, method: requestType, parameters: requestParameter, encoding: JSONEncoding.default, headers: requestHeaders).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                let configData = response.data
                
                if configData != nil {
                    responseForConfiguration(configData!, true)
                }
                else
                {
                    responseForConfiguration(nil, false)
                }
            case .failure:
                
                let errorData = response.data
                
                if errorData != nil {
                    
                    responseForConfiguration(errorData!, false)
                }
                else  {
                    
                    responseForConfiguration(nil, false)
                }
            }
        }
    }
    
    private func encodeAuthorizationForUrbanAirship() -> String? {
        
        if let filePath = Bundle.main.path(forResource: "AirshipConfig", ofType: "plist") {
            
            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: filePath)!
            let appKey = dicRoot["PRODUCTION_APP_KEY"] as? String
            
            if appKey != nil && AppConfiguration.sharedAppConfiguration.urbanAirshipProdMasterKey != nil {
                
                let preEncodedString = "\(appKey!):\(AppConfiguration.sharedAppConfiguration.urbanAirshipProdMasterKey!)"
                
                let utf8Str = preEncodedString.data(using: .utf8)
                
                if let base64EncodedString = utf8Str?.base64EncodedString(options: .init(rawValue: 0)) {
                    
                    return "Basic \(base64EncodedString)"
                }
            }
        }
        
        return nil
    }
    #endif
}


