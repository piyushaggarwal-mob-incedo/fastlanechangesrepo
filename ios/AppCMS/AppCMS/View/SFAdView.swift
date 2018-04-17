//
//  SFAdView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit
import GoogleMobileAds

@objc protocol AdViewDelegate:NSObjectProtocol {
    
    @objc optional func updateAdViewTrayHeight(adViewHeight:CGFloat) -> Void
}

class SFAdView: UIView, GADBannerViewDelegate {

    var adViewObject:SFAdViewObject?
    var relativeViewFrame:CGRect?
    var adViewLayout:LayoutObject?
    var adView:GADBannerView?
    var adType:GADAdSize?
    var adUnitID: String?
    weak var delegate:AdViewDelegate?
    
    func initialiseAdViewFrameFromLayout(adViewLayout:LayoutObject, adType:GADAdSize, adUnitId:String) {
        
        self.adType = adType
        self.adUnitID = adUnitId
        self.frame = Utility.initialiseViewLayout(viewLayout: adViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createAdView() {
        
        adView = GADBannerView(adSize: adType ?? kGADAdSizeBanner)
        self.addSubview(adView!)
        adView?.adUnitID = adUnitID ?? ""
        adView?.rootViewController = Constants.kAPPDELEGATE.window?.rootViewController
        adView?.load(GADRequest())
        adView?.delegate = self
    }
    
    
    //MARK: Update AdSize on orientation change
    func updateAdSizeOnOrientationChange() {
        
        adView?.adSize = adType!
    }

    //MARK: Ad View Delegates
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        if delegate != nil && (delegate?.responds(to: #selector(AdViewDelegate.updateAdViewTrayHeight(adViewHeight:))))! {

            delegate?.updateAdViewTrayHeight!(adViewHeight: bannerView.frame.size.height)
        }
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        
        if delegate != nil && (delegate?.responds(to: #selector(AdViewDelegate.updateAdViewTrayHeight(adViewHeight:))))! {

            delegate?.updateAdViewTrayHeight!(adViewHeight: 0.0)
        }
    }
}
