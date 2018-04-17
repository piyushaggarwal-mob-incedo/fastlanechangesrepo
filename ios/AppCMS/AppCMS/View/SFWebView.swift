//
//  SFWebView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 09/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import WebKit

class SFWebView: WKWebView {

    var webViewObject:SFWebViewObject?
    var relativeViewFrame:CGRect?
    var webViewLayout:LayoutObject?
    
    func initialiseWebViewFrameFromLayout(webViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: webViewLayout, relativeViewFrame: relativeViewFrame!)
        self.backgroundColor = .clear
        self.scrollView.backgroundColor = .clear
        self.isOpaque = false
    }
    
    func openUrlOnWebView(webUrl:URL) {
        
        let urlRequest = URLRequest(url: webUrl)
        self.load(urlRequest)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
