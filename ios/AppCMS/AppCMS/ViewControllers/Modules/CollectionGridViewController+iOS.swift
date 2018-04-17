//
//  CollectionGridViewController+iOS.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import WebKit
import GoogleMobileAds

extension CollectionGridViewController: WKNavigationDelegate, AdViewDelegate {
    
    //MARK: Method to create ad view
    func createAdView(adViewObject:SFAdViewObject) {
        
        let adViewLayout = Utility.fetchAdViewLayoutDetails(adViewObject: adViewObject)
        
        let adView:SFAdView = SFAdView(frame: .zero)
        adView.adViewObject = adViewObject
        adView.relativeViewFrame = relativeViewFrame!
        adView.adViewLayout = adViewLayout
        adView.delegate = self
        adView.initialiseAdViewFrameFromLayout(adViewLayout: adViewLayout, adType: UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait, adUnitId: moduleAPIObject?.moduleRawText ?? "")
        self.view.addSubview(adView)
        adView.createAdView()
    }
    
    
    //MARK: Method to create web view
    func createWebView(webViewObject:SFWebViewObject) {
        
        let webView:SFWebView = SFWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration.init())
        webView.webViewObject = webViewObject
        webView.relativeViewFrame = relativeViewFrame!
        
        if webViewObject.isWebViewInteractive != nil {
            
            self.isWebViewInteractive = (webViewObject.isWebViewInteractive)!
        }
        
        if webViewObject.shouldNavigateToExternalBrowser != nil {
            
            self.shouldNavigateToExternalBrowser = webViewObject.shouldNavigateToExternalBrowser!
        }
        
        webView.initialiseWebViewFrameFromLayout(webViewLayout: Utility.fetchWebViewLayoutDetails(webViewObject: webViewObject))
        self.view.addSubview(webView)
        
        if let webUrlString = moduleAPIObject?.moduleRawText {
            
            if let webUrl = URL(string: webUrlString) {
                
                webView.openUrlOnWebView(webUrl: webUrl)
                
                webView.navigationDelegate = self
                webView.goForward()
            }
        }
    }
    
    
    //MARK: Web view delegates
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if self.isWebViewInteractive {
            
            if navigationAction.navigationType == .linkActivated {
                
                if self.shouldNavigateToExternalBrowser {
                    
                    if let webUrl = navigationAction.request.url {
                        
                        UIApplication.shared.openURL(webUrl)
                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
        
    }
    
    //MARK: Ad View Delegates
    /// Tells the delegate an ad request loaded an ad.
    func updateAdViewTrayHeight(adViewHeight: CGFloat) {
        
        if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.updateAdViewTrayHeight(adViewHeight:cellIndex:))))! {
            
            delegate?.updateAdViewTrayHeight!(adViewHeight: adViewHeight, cellIndex: cellIndex ?? 0)
        }
    }
    

    //MARK: AdView frame update on orientation change
    func updateAdSizeOnOrientationChange(adView:SFAdView) {
        
        let adViewLayout = Utility.fetchAdViewLayoutDetails(adViewObject: adView.adViewObject!)
        adView.relativeViewFrame = relativeViewFrame!
        adView.initialiseAdViewFrameFromLayout(adViewLayout: adViewLayout, adType: UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait, adUnitId: moduleAPIObject?.moduleRawText ?? "")
        adView.updateAdSizeOnOrientationChange()
    }
    
    
    //MARK: Webview frame update on orientation change
    func updateWebViewFrame(webView:SFWebView) {
        
        webView.relativeViewFrame = relativeViewFrame
        webView.initialiseWebViewFrameFromLayout(webViewLayout: Utility.fetchWebViewLayoutDetails(webViewObject: webView.webViewObject!))
    }
}
