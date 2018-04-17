//
//  Utility+tvOS.swift
//  AppCMS
//
//  Created by Gaurav Vig on 15/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension Utility {
    
    class func getCurrentTypeValue(pageTypeName: String) -> Int
    {
        var pageTypeInt: Int = 0
        
        if pageTypeName == Constants.kSTRING_PAGETYPE_DEFAULT {
            pageTypeInt = 0
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_WEBPAGE {
            pageTypeInt = 1
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_NATIVE
        {
            pageTypeInt = 2
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_MODULAR
        {
            pageTypeInt = 3
        }
        return pageTypeInt
    }
    
    class func fetchLabelLayoutDetails(labelObject:SFLabelObject) -> LayoutObject {
        
        var labelLayout:LayoutObject?
        labelLayout = labelObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return labelLayout!
    }
    
    class func fetchSwitchViewLayoutDetails(switchViewObject:SFSwitchViewObject) -> LayoutObject {
        
        var switchLayout:LayoutObject?
        switchLayout = switchViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return switchLayout!
    }
    
    class func fetchLoaderViewLayoutDetails(loaderObject:SFTimerLoaderViewObject) -> LayoutObject {
        
        var loaderLayout:LayoutObject?
        loaderLayout = loaderObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return loaderLayout!
    }
    
    class func fetchHeaderLayoutDetails(headerObject:SFHeaderViewObject) -> LayoutObject {
        
        var headerLayout:LayoutObject?
        headerLayout = headerObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return headerLayout!
    }
    
    class func fetchFooterLayoutDetails(footerObject:SFFooterViewObject) -> LayoutObject {
        
        var footerLayout:LayoutObject?
        footerLayout = footerObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return footerLayout!
    }
    
    class func fetchButtonLayoutDetails(buttonObject:SFButtonObject) -> LayoutObject {
        
        var buttonLayout:LayoutObject?
        buttonLayout = buttonObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return buttonLayout!
    }
    
    func fetchTableViewLayoutDetails(tableViewObject:SFTableViewObject) -> LayoutObject {
        
        var tableViewLayout:LayoutObject?
        tableViewLayout = tableViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return tableViewLayout!
    }
    
    class func fetchImageLayoutDetails(imageObject:SFImageObject) -> LayoutObject {
        
        var imageLayout:LayoutObject?
        imageLayout = imageObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return imageLayout!
    }
    
    class func fetchCarouselItemLayoutDetails(carouselObject:SFCarouselItemObject) -> LayoutObject {
        
        var carouselItemLayout:LayoutObject?
        carouselItemLayout = carouselObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return carouselItemLayout!
    }
    
    class func fetchTextViewLayoutDetails(textViewObject:SFTextViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        textViewLayout = textViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return textViewLayout!
    }
    
    
    class func fetchSeparatorViewLayoutDetails(separatorViewObject:SFSeparatorViewObject) -> LayoutObject {
        
        var separatorViewLayout:LayoutObject?
        separatorViewLayout = separatorViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return separatorViewLayout!
    }
    
    class func fetchCollectionGridLayoutDetails(collectionGridObject:SFCollectionGridObject) -> LayoutObject {
        
        var collectionGridLayout:LayoutObject?
        collectionGridLayout = collectionGridObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return collectionGridLayout!
    }
    
    class func fetchTrayLayoutDetails(trayObject:SFTrayObject) -> LayoutObject {
        
        var trayLayout:LayoutObject?
        trayLayout = trayObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return trayLayout!
    }
    
    class func fetchTextFieldLayoutDetails(textFieldObject:SFTextFieldObject) -> LayoutObject {
        
        var textFieldLayout:LayoutObject?
        textFieldLayout = textFieldObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return textFieldLayout!
    }
    
    
    class func fetchVideoDetailLayoutDetails(videoDetailObject: SFVideoDetailModuleObject) -> LayoutObject
    {
        var videoLayout:LayoutObject?
        videoLayout = videoDetailObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return videoLayout!
    }
    
    class func fetchWatchlistLayoutDetails(watchListObject: SFWatchlistAndHistoryViewObject) -> LayoutObject
    {
        var layout:LayoutObject?
        layout = watchListObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return layout!
    }
    
    class func fetchLoginViewLayoutDetails(loginViewObject: LoginViewObject_tvOS) -> LayoutObject
    {
        var loginViewLayout:LayoutObject?
        loginViewLayout = loginViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return loginViewLayout!
    }
    
    class func fetchAncillaryViewLayoutDetails(ancillaryViewObject: AncillaryViewObject_tvOS) -> LayoutObject
    {
        var ancillaryViewLayout:LayoutObject?
        ancillaryViewLayout = ancillaryViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return ancillaryViewLayout!
    }
    
    class func fetchContactUsViewLayoutDetails(ContactUsViewObject: ContactUsViewObject_tvOS) -> LayoutObject
    {
        var contactUsViewLayout:LayoutObject?
        contactUsViewLayout = ContactUsViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return contactUsViewLayout!
    }
    
    class func fetchSubscriptionViewLayoutDetails(SubscriptionViewObject: SubscriptionViewObject_tvOS) -> LayoutObject
    {
        var subscriptionViewLayout:LayoutObject?
        subscriptionViewLayout = SubscriptionViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return subscriptionViewLayout!
    }
    class func fetchPlanMetaDataViewLayoutDetails(planMetaDataViewObject:SFPlanMetaDataViewObject) -> LayoutObject {
        
        var planMetaDataLayout:LayoutObject?
        planMetaDataLayout = planMetaDataViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return planMetaDataLayout!
    }
    
    class func fetchSettingsViewLayoutDetails(settingViewObject: SettingViewObject_tvOS) -> LayoutObject
    {
        var settingViewLayout:LayoutObject?
        settingViewLayout = settingViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return settingViewLayout!
    }
    
    
    class func fetchProgresViewLayoutDetails(progressViewObject:SFProgressViewObject) -> LayoutObject {
        
        var progressViewLayout:LayoutObject?
        progressViewLayout = progressViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return progressViewLayout!
    }
    
    class func fetchCarouselLayoutDetails(carouselViewObject:SFJumbotronObject) -> LayoutObject {
        
        var carouselViewLayout:LayoutObject?
        carouselViewLayout = carouselViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return carouselViewLayout!
    }
    
    class func fetchPageControlLayoutDetails(pageControlObject:SFPageControlObject) -> LayoutObject {
        
        var pageControlLayout:LayoutObject?
        pageControlLayout = pageControlObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return pageControlLayout!
    }
    
    class func fetchLayoutDetailsFromDictionary(layoutObjectDict:Dictionary<String, LayoutObject>) -> LayoutObject {
        
        var layoutObject:LayoutObject?
        layoutObject = layoutObjectDict[Constants.kSTRING_AppleTV]
        return layoutObject!
    }
    
    class func getBaseScreenHeightMultiplier() -> CGFloat {
        
        return 1.0
    }
    
    class func getBaseScreenWidthMultiplier() -> CGFloat {
        
        return 1.0
    }
    
    class func createCustomParallaxEffect(_ value: Int, withTiltValue tiltValue: Double) -> UIMotionEffectGroup {
        let motionEffectGroup = UIMotionEffectGroup()
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = Int(-value)
        horizontalMotionEffect.maximumRelativeValue = Int(value)
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = Int(-value)
        verticalMotionEffect.maximumRelativeValue = Int(value)
        let horizontalTiltMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform.rotation.y", type: .tiltAlongHorizontalAxis)
        horizontalTiltMotionEffect.minimumRelativeValue = Int(-tiltValue)
        horizontalTiltMotionEffect.maximumRelativeValue = Int(tiltValue)
        return motionEffectGroup
    }
    //MARK: Method to fetch star rating view layout details
    class func fetchStarRatingLayoutDetails(starRatingObject:SFStarRatingObject) -> LayoutObject {
        var starRatingLayout:LayoutObject?
        starRatingLayout = starRatingObject.layoutObjectDict["\(Constants.kSTRING_AppleTV)"]
        return starRatingLayout!
    }
    class func fetchCastViewLayoutDetails(castViewObject:SFCastViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        textViewLayout = castViewObject.layoutObjectDict["\(Constants.kSTRING_AppleTV)"]
        return textViewLayout!
    }
    
    //MARK: - Helper methods
    func calculateWidthOfText (_ menuTitle : String, _ titleFont: String, _ titleFontSize: CGFloat ) -> CGRect
    {
        let font : UIFont = UIFont(name: titleFont, size: titleFontSize + 2)!
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuTitle.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return  boundingBox
    }
    
    class func getTextAlignment(textAlignmentString: String) -> NSTextAlignment{
        switch textAlignmentString {
        case "center":
            return .center
        case "left":
            return .left
        case "right":
            return .right
        default:
            return .left
        }
    }
    
    class func addMotionEffectToViewWithStrength (viewItem : UIView, strength : Float) {
        removeMotionEffectFromView(viewItem: viewItem)
        viewItem.addMotionEffect(UIMotionEffect.twoAxesShift(strength: strength))
    }
    
    class func removeMotionEffectFromView (viewItem : UIView) {
        var ii = 0
        while ii < (viewItem.motionEffects.count) {
            var motionEffect = viewItem.motionEffects[ii]
            if motionEffect is UIMotionEffectGroup {
                motionEffect = motionEffect as! UIMotionEffectGroup
                viewItem.removeMotionEffect(motionEffect)
            }
            ii = ii + 1
        }
    }
    
}
