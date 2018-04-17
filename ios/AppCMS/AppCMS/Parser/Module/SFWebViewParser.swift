//
//  SFWebViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 09/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFWebViewParser: NSObject {

 func parseWebViewJson(webViewDictionary: Dictionary<String, AnyObject>) -> SFWebViewObject
   {
        let webViewObject = SFWebViewObject()
        
        webViewObject.type = webViewDictionary["type"] as? String
        webViewObject.keyName = webViewDictionary["key"] as? String
        webViewObject.isWebViewInteractive = webViewDictionary["isWebViewInteractive"] as? Bool
        webViewObject.shouldNavigateToExternalBrowser = webViewDictionary["shouldNavigateToExternalBrowser"] as? Bool
        
        let layoutDict = webViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            webViewObject.layoutObjectDict = layoutObjectDict
        }
        
        return webViewObject
    }
}
