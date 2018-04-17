//
//  Utility+iOS.swift
//  AppCMS
//
//  Created by Gaurav Vig on 15/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import Firebase

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
        else if pageTypeName == Constants.kSTRING_PAGETYPE_WELCOME
        {
            pageTypeInt = 4
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_DOWNLOAD
        {
            pageTypeInt = 5
        }
        
        return pageTypeInt
    }
    
    //MARK: Method to fetch label layout details
    class func fetchLabelLayoutDetails(labelObject:SFLabelObject) -> LayoutObject {
        
        var labelLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            labelLayout = labelObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                labelLayout = labelObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                labelLayout = labelObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return labelLayout!
    }
    
    //MARK: Method to fetch button layout details
    class func fetchButtonLayoutDetails(buttonObject:SFButtonObject) -> LayoutObject {
        
        var buttonLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            buttonLayout = buttonObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                buttonLayout = buttonObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                buttonLayout = buttonObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return buttonLayout!
    }
    
    //MARK: Method to fetch toggle layout details
    class func fetchToggleLayoutDetails(toggleObject:SFToggleObject) -> LayoutObject {
        
        var toggleLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            toggleLayout = toggleObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                toggleLayout = toggleObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                toggleLayout = toggleObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return toggleLayout!
    }
    
    
    //MARK: Method to fetch image view layout details
    class func fetchImageLayoutDetails(imageObject:SFImageObject) -> LayoutObject {
        
        var imageLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            imageLayout = imageObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                imageLayout = imageObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                imageLayout = imageObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return imageLayout!
    }
    
    
    //MARK: Method to fetch star rating view layout details
    class func fetchStarRatingLayoutDetails(starRatingObject:SFStarRatingObject) -> LayoutObject {
        
        var starRatingLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            starRatingLayout = starRatingObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                starRatingLayout = starRatingObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                starRatingLayout = starRatingObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return starRatingLayout!
    }
    
    
    //MARK: Method to fetch text view layout details
    class func fetchTextViewLayoutDetails(textViewObject:SFTextViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            textViewLayout = textViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                textViewLayout = textViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                textViewLayout = textViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return textViewLayout!
    }
    
    
    //MARK: Method to fetch text field layout details
    class func fetchTextFieldLayoutDetails(textFieldObject:SFTextFieldObject) -> LayoutObject {
        
        var textFieldLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            textFieldLayout = textFieldObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                textFieldLayout = textFieldObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                textFieldLayout = textFieldObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return textFieldLayout!
    }
    
    
    //MARK: Method to fetch drop down layout details
    class func fetchDropDownLayoutDetails(dropDownObject:SFDropDownObject) -> LayoutObject {
        
        var dropDownLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            dropDownLayout = dropDownObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                dropDownLayout = dropDownObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                dropDownLayout = dropDownObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return dropDownLayout!
    }
    
    
    //MARK: Method to fetch cast view layout details
    class func fetchCastViewLayoutDetails(castViewObject:SFCastViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            textViewLayout = castViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                textViewLayout = castViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                textViewLayout = castViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return textViewLayout!
    }
    
    
    //MARK: Method to fetch separator view layout details
    class func fetchSeparatorViewLayoutDetails(separatorViewObject:SFSeparatorViewObject) -> LayoutObject {
        
        var separatorViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            separatorViewLayout = separatorViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                separatorViewLayout = separatorViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                separatorViewLayout = separatorViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return separatorViewLayout!
    }
    
    
    //MARK: Method to fetch segment view layout details
    class func fetchSegmentViewLayoutDetails(segmentViewObject:SFSegmentObject) -> LayoutObject {
        
        var segmentViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            segmentViewLayout = segmentViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                segmentViewLayout = segmentViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                segmentViewLayout = segmentViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return segmentViewLayout!
    }
    
    
    //MARK: Method to fetch collection grid layout details
    class func fetchCollectionGridLayoutDetails(collectionGridObject:SFCollectionGridObject) -> LayoutObject {
        
        var collectionGridLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            collectionGridLayout = collectionGridObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                collectionGridLayout = collectionGridObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                collectionGridLayout = collectionGridObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return collectionGridLayout!
    }
    
    
    //MARK: Method to fetch tray layout details
    class func fetchTrayLayoutDetails(trayObject:SFTrayObject) -> LayoutObject {
        
        var trayLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            trayLayout = trayObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                trayLayout = trayObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                trayLayout = trayObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return trayLayout!
    }
    
    
    //MARK: Method to fetch video detail layout details
    class func fetchVideoDetailLayoutDetails(videoDetailObject: SFVideoDetailModuleObject) -> LayoutObject
    {
        var videoLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            videoLayout = videoDetailObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                videoLayout = videoDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                videoLayout = videoDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return videoLayout!
    }
    
    
    //MARK: Method to fetch show detail layout details
    class func fetchShowDetailLayoutDetails(showDetailObject: SFShowDetailModuleObject) -> LayoutObject
    {
        var showLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            showLayout = showDetailObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                showLayout = showDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                showLayout = showDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return showLayout!
    }
    
    
    //MARK: Method to fetch autoplay layout details
    class func fetchAutoPlayDetailLayoutDetails(autoPlayViewObject: SFAutoplayObject) -> LayoutObject
    {
        var videoLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            videoLayout = autoPlayViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                videoLayout = autoPlayViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                videoLayout = autoPlayViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return videoLayout!
    }
    
    //MARK: Method to fetch article layout details
    class func fetchArticleDetailLayoutDetails(articleDetailObject: SFArticleDetailObject) -> LayoutObject
    {
        var articleLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            articleLayout = articleDetailObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                articleLayout = articleDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                articleLayout = articleDetailObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return articleLayout!
    }
    
    //MARK: Method to fetch progress view layout details
    class func fetchProgresViewLayoutDetails(progressViewObject:SFProgressViewObject) -> LayoutObject {
        
        var progressViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            progressViewLayout = progressViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                progressViewLayout = progressViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                progressViewLayout = progressViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return progressViewLayout!
    }
    
    
    //MARK: Method to fetch carousel layout details
    class func fetchCarouselLayoutDetails(carouselViewObject:SFJumbotronObject) -> LayoutObject {
        
        var carouselViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            carouselViewLayout = carouselViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                carouselViewLayout = carouselViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                carouselViewLayout = carouselViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return carouselViewLayout!
    }
    
    
    //MARK: Method to fetch page control layout details
    class func fetchPageControlLayoutDetails(pageControlObject:SFPageControlObject) -> LayoutObject {
        
        var pageControlLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            pageControlLayout = pageControlObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                pageControlLayout = pageControlObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                pageControlLayout = pageControlObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return pageControlLayout!
    }
    
    
    //MARK: Method to fetch tableview layout details
    func fetchTableViewLayoutDetails(tableViewObject:SFTableViewObject) -> LayoutObject {
        
        var tableViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            tableViewLayout = tableViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                tableViewLayout = tableViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                tableViewLayout = tableViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return tableViewLayout!
    }
    
    //MARK: Method to fetch plan metadata view layout details
    class func fetchPlanMetaDataViewLayoutDetails(planMetaDataViewObject:SFPlanMetaDataViewObject) -> LayoutObject {
        
        var planMetaDataLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            planMetaDataLayout = planMetaDataViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                planMetaDataLayout = planMetaDataViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                planMetaDataLayout = planMetaDataViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return planMetaDataLayout!
    }
    
    //MARK: Method to fetch user account layout details
    class func fetchUserAccountViewLayoutDetails(userAccountViewObject:UserAccountComponentObject) -> LayoutObject {
        
        var userAccountViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            userAccountViewLayout = userAccountViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                userAccountViewLayout = userAccountViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                userAccountViewLayout = userAccountViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return userAccountViewLayout!
    }
    
    //MARK: Method to fetch layout details
    class func fetchLayoutDetailsFromDictionary(layoutObjectDict:Dictionary<String, LayoutObject>) -> LayoutObject {
        
        var layoutObject:LayoutObject?
        
        if Constants.IPHONE {
            
            layoutObject = layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                layoutObject = layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                layoutObject = layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return layoutObject!
    }
    
    //MARK: Method to fetch download quality layout details
    class func fetchDownloadQualityLayoutDetails(downloadQualityViewObject: SFDownloadQualityObject) -> LayoutObject
    {
        var layout:LayoutObject?
        
        if Constants.IPHONE {
            
            layout = downloadQualityViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                layout = downloadQualityViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                layout = downloadQualityViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return layout!
    }
    
    
    //MARK: Method to fetch webview layout details
    class func fetchWebViewLayoutDetails(webViewObject: SFWebViewObject) -> LayoutObject
    {
        var layout:LayoutObject?
        
        if Constants.IPHONE {
            
            layout = webViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                layout = webViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                layout = webViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        return layout!
    }
    
    
    //MARK: Method to fetch list view layout details
    class func fetchListViewLayoutDetails(listViewObject:SFListViewObject) -> LayoutObject {
        
        var listViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            listViewLayout = listViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                listViewLayout = listViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                listViewLayout = listViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return listViewLayout!
    }
    
    //MARK: Method to fetch bannerview layout details
    class func fetchBannerViewLayoutDetails(bannerViewObject:SFBannerViewObject) -> LayoutObject {
        
        var bannerViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            bannerViewLayout = bannerViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                bannerViewLayout = bannerViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                bannerViewLayout = bannerViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return bannerViewLayout!
    }
    
    
    //MARK: Method to fetch drop down button view layout details
    class func fetchDropDownButtonViewLayoutDetails(dropDownButtonObject:SFDropDownButtonObject) -> LayoutObject {
        
        var dropDownButtonLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            dropDownButtonLayout = dropDownButtonObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                dropDownButtonLayout = dropDownButtonObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                dropDownButtonLayout = dropDownButtonObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return dropDownButtonLayout!
    }
    
    
    //MARK: Method to fetch label layout details
    class func fetchAdViewLayoutDetails(adViewObject:SFAdViewObject) -> LayoutObject {
        
        var adViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            adViewLayout = adViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                adViewLayout = adViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                adViewLayout = adViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return adViewLayout!
    }
    
    //MARK: Method to fetch tray layout details
    class func fetchVerticalArticleViewLayoutDetails(verticalArticleViewObject:SFVerticalArticleViewObject) -> LayoutObject {
        
        var verticalArticleViewLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            verticalArticleViewLayout = verticalArticleViewObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                verticalArticleViewLayout = verticalArticleViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                verticalArticleViewLayout = verticalArticleViewObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return verticalArticleViewLayout!
    }
    
    //MARK: Method to fetch label layout details
    class func fetchArticleMetadataViewLayoutDetails(articleMetadataObject:SFVerticalArticleMetadataObject) -> LayoutObject {
        
        var articleMetadataLayout:LayoutObject?
        
        if Constants.IPHONE {
            
            articleMetadataLayout = articleMetadataObject.layoutObjectDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]
        }
        else {
            
            if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                
                articleMetadataLayout = articleMetadataObject.layoutObjectDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"]
            }
            else {
                
                articleMetadataLayout = articleMetadataObject.layoutObjectDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"]
            }
        }
        
        return articleMetadataLayout!
    }
    
    class func getBaseScreenHeightMultiplier() -> CGFloat {
        
        var baseScreenMultiplier:CGFloat = 0.0
        let heightOfScreen = UIScreen.main.bounds.size.height
        let widthOfScreen = UIScreen.main.bounds.size.width
        
        if Constants.IPHONE {
            
            if heightOfScreen > widthOfScreen {
                baseScreenMultiplier = heightOfScreen / 667
                if Utility.sharedUtility.isIphoneX() {
                    baseScreenMultiplier = 1;
                }
            }
            else {
                
                baseScreenMultiplier = heightOfScreen / 375
            }
        }
        else {
            
            if heightOfScreen > widthOfScreen {
                
                baseScreenMultiplier = heightOfScreen / 1024
            }
            else {
                
                baseScreenMultiplier = heightOfScreen / 768
            }
        }
        
        return baseScreenMultiplier
    }
    
    class func getBaseScreenWidthMultiplier() -> CGFloat {
        
        var baseScreenMultiplier:CGFloat = 0.0
        let heightOfScreen = UIScreen.main.bounds.size.height
        let widthOfScreen = UIScreen.main.bounds.size.width
        
        if Constants.IPHONE {
            
            if heightOfScreen > widthOfScreen {
                
                baseScreenMultiplier = widthOfScreen / 375
            }
            else {
                
                baseScreenMultiplier = widthOfScreen / 667
            }
        }
        else {
            
            if heightOfScreen > widthOfScreen {
                
                baseScreenMultiplier = widthOfScreen / 768
            }
            else {
                
                baseScreenMultiplier = widthOfScreen / 1024
            }
        }
        
        return baseScreenMultiplier
    }
    
    //MARK:Get downloaded videoSize
    func getdownloadedVideoSize(id:String) -> String? {
        
        return "20 MB"
    }
    
    func getdownloadedVideoSize(_ value: Double) -> String {
        var convertedValue = value
        var multiplyFactor: Int = 0
        let tokens: [String] = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        if Int(convertedValue) > 0 {
            return " \(Int(convertedValue)) \(tokens[multiplyFactor])"
        }
        else{
            return ""
        }
    }

    
    //MARK: Show Download max capacity popup
    func showAlertOnFullDownlaodCapacity() {
        let alertController = UIAlertController(title: "", message: Constants.kDownloadCapacityError, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            print("NO action")
        })
        let yesAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            //TODO show download page
        })
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        //Show alertcontroller.
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController as UIViewController, animated: true) { _ in }
    }
    
    func showAlertController(alertTitle: String, alertMessage:String, alertActions:Array<UIAlertAction>) -> Void {
        
        let alertController:UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        for action:UIAlertAction in alertActions {
            
            alertController.addAction(action)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController as UIViewController, animated: true) { _ in }
    }
    
    func checkIfDownloadAlertToBeDisplayedInOfflineMode() -> Bool {
        
        var showDownloadAlert = false
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil {
                
                if AppConfiguration.sharedAppConfiguration.isDownloadEnabled == true {
                    
                    showDownloadAlert = true
                }
            }
        }
        
        return showDownloadAlert
    }
    
    
    func displayOfflineAlertToPlayDownloadVideo(viewController:UIViewController) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
        }
        
        let okAction = UIAlertAction(title: Constants.kStrMyDownloads, style: .default) { (okAction) in
            
            self.loadDownloadController(pageName: "My Downloads", pagePath: "/user/downloads", viewController: viewController)
        }
        var message = ""
        if  TEMPLATETYPE.lowercased() != Constants.kTemplateTypeSports.lowercased() {
            message = " movies."
        }
        else{
            message = " videos."
        }
        message = Constants.kStrOfflineWatchVideoError + message
        let offlineDownloadAlert:UIAlertController = self.presentAlertController(alertTitle: "Network Error", alertMessage: message, alertActions: [cancelAction, okAction])
        viewController.present(offlineDownloadAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Method to load ancillary view controller
    func loadDownloadController(pageName:String, pagePath:String, viewController:UIViewController) {
        
        var viewControllerPage:Page?
        
        let pageId:String? = self.getPageIdFromPagesArray(pageName: pageName)
        
        if pageId != nil {
            let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageId!)
            
            if !filePath.isEmpty {
                
                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                
                if jsonData != nil {
                    
                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                    viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                }
            }
            
            if viewControllerPage != nil {
                
                let downloadViewController:DownloadViewController = DownloadViewController(viewControllerPage: viewControllerPage!)
                downloadViewController.view.changeFrameYAxis(yAxis: 20.0)
                downloadViewController.view.changeFrameHeight(height: downloadViewController.view.frame.height - 20.0)
                downloadViewController.pagePath = pagePath
                viewController.present(downloadViewController, animated: true, completion: nil)
            }
        }
    }
    
    func checkIfGoogleTagMangerAvailable() -> Bool {
        
        var isGTMAvailable:Bool = false
        
        guard let filePath:String = (Bundle.main.resourcePath?.appending("/GoogleService-Info.plist")) else { return isGTMAvailable }
        
        if AppConfiguration.sharedAppConfiguration.googleTagManagerId != nil {
            
            if FileManager.default.fileExists(atPath: filePath) {
                
                if AppConfiguration.sharedAppConfiguration.googleTagManagerId != "" {
                    
                    isGTMAvailable = true
                }
            }
        }
        
        return isGTMAvailable
    }
    
    func setGTMUserProperty(userPropertyValue:String, userPropertyKeyName:String) {
        
        FIRAnalytics.setUserPropertyString(userPropertyValue, forName: userPropertyKeyName)
    }
    
    //MARK :- Check if video is downloaded or not
    func checkIfMovieIsDownloaded(fileID : String) -> Bool {
        
        var isMovieDownloaded = false
        
        if (DownloadManager.sharedInstance.checkIfFolderExist(withFileName: fileID) == true) {
            
            let state:downloadObjectState = downloadObjectState(rawValue: DownloadManager.sharedInstance.getCurrentDownloadStateForFile(withFileID: fileID)) ?? downloadObjectState.eDownloadStateNone
            
            if state == downloadObjectState.eDownloadStateFinished {
                
                isMovieDownloaded = true
            }
        }
        
        return isMovieDownloaded
    }
    
    
    //MARK: Get top view controller from window
    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    func isIphoneX() -> Bool {
        return self.isDeviceIphoneX
    }

    func getPosition(position:CGFloat) -> CGFloat {
        var value = position
        if (Constants.IPHONE && self.isIphoneX()) {
            value = value + 10;
        }
        return value;
    }
    
    func displayLoginView() -> Void {
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        navigationController.present()
    }
    
    func displayPlanPage() -> Void {
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
        navigationController.present()
    }
    
    class func presentKiswePlayer(forEventId eventID: String, withFilmId filmID: String, vc:UIViewController?) {
        vc?.view.isUserInteractionEnabled = false
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            vc?.view.isUserInteractionEnabled = true
            if Utility.sharedUtility.checkIfUserIsLoggedIn(){
                if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                    Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: vc!)
                }
            }
            else{
                let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                })
                let paymentNetworkAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: Constants.kInternetConntectionRefresh, alertActions: [okAction])
                paymentNetworkAlert.show()
            }
        }
        else{
            if Utility.sharedUtility.checkIfUserIsLoggedIn(){
                if (AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD){
                    DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                        DispatchQueue.main.async {
                            if isSubscribed != nil {
                                if isSubscribed == true {
                                    let kisweVC = KisweBaseViewController.init()
                                    if vc != nil{
                                        kisweVC.delegate = vc as? SFKisweBaseViewControllerDelegate
                                    }
                                    kisweVC.eventID = eventID
                                    kisweVC.filmId = filmID
                                    let navigationController = UINavigationController.init(rootViewController: kisweVC)
                                    navigationController.present()
                                }
                                else{
                                    vc?.view.isUserInteractionEnabled = true
                                    let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in

                                    }
                                    let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
                                        Utility.sharedUtility.displayPlanPage()
                                    }
                                    var alertActionArray:Array<UIAlertAction>?
                                    
                                    alertActionArray = [cancelAction, subscriptionAction]
                                    let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: Constants.kEntitlementErrorMessage, alertActions: alertActionArray!)
                                    nonEntitledAlert.show()
                                }
                            }
                        }
                    })
                }
                else{
                    let kisweVC = KisweBaseViewController.init()
                    if vc != nil{

                        kisweVC.delegate = vc as? SFKisweBaseViewControllerDelegate
                    }
                    kisweVC.eventID = eventID
                    kisweVC.filmId = filmID
                    let navigationController = UINavigationController.init(rootViewController: kisweVC)
                    navigationController.present()
                }
            }
            else{
                vc?.view.isUserInteractionEnabled = true
                let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
                }
                let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
                    Utility.sharedUtility.displayLoginView()
                }
                let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
                    Utility.sharedUtility.displayPlanPage()
                }
                var alertActionArray:Array<UIAlertAction>?
                
                if (AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD){
                    alertActionArray = [cancelAction, signInAction, subscriptionAction]
                }
                else{
                    alertActionArray = [cancelAction, signInAction]
                }
                
                let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: Constants.kEntitlementErrorMessage, alertActions: alertActionArray!)
                
                nonEntitledAlert.show()
            }
        }
    }

    func presentMorePopUP(morePopUpViewController : SFMorePopUpViewController) -> Void {
        if let topController = Utility.sharedUtility.topViewController() {

            if topController.navigationController != nil {

                topController.navigationController?.addChildViewController(morePopUpViewController)
                topController.navigationController?.view.addSubview(morePopUpViewController.view)
            }
            else {
                topController.addChildViewController(morePopUpViewController)
                topController.view.addSubview(morePopUpViewController.view)
            }
        }
    }

    private func displayMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, contentType:String?, isModel:Bool?, delegate:SFMorePopUpViewControllerDelegate?){
        let morePopUpViewController:SFMorePopUpViewController = SFMorePopUpViewController(contentId: contentId, contentType: contentType, moreOptionArray: moreOptionArray)
        morePopUpViewController.view.frame = UIScreen.main.bounds
        morePopUpViewController.delegate = delegate
        if let isMod = isModel{
            if !isMod {
                Constants.kAPPDELEGATE.window?.rootViewController?.addChildViewController(morePopUpViewController)
                Constants.kAPPDELEGATE.window?.rootViewController?.view.addSubview(morePopUpViewController.view)
            }
            else {
                self.presentMorePopUP(morePopUpViewController: morePopUpViewController)
            }
        }
        else{
            self.presentMorePopUP(morePopUpViewController: morePopUpViewController)
        }
    }

    class func presentMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, contentType:String?, isModel:Bool?, delegate:SFMorePopUpViewControllerDelegate?, isOptionForBannerView: Bool) {
        
        if let contentId = contentId, let contentType = contentType {
            
            Utility.sharedUtility.displayMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isModel: isModel, delegate: delegate)
        }
        else {
            
            if isOptionForBannerView {
                
                let morePopUpViewController:SFMorePopUpViewController = SFMorePopUpViewController.init(contentId: contentId, moreOptionArray: moreOptionArray)
                morePopUpViewController.view.frame = UIScreen.main.bounds
                morePopUpViewController.delegate = delegate
                if let isMod = isModel{
                    if !isMod {
                        Constants.kAPPDELEGATE.window?.rootViewController?.addChildViewController(morePopUpViewController)
                        Constants.kAPPDELEGATE.window?.rootViewController?.view.addSubview(morePopUpViewController.view)
                    }
                    else {
                        
                        Utility.sharedUtility.presentMorePopUP(morePopUpViewController: morePopUpViewController)
                    }
                }
                else{
                    
                    Utility.sharedUtility.presentMorePopUP(morePopUpViewController: morePopUpViewController)
                }
            }
        }
    }
    
    
    //MARK: Method to pick font family for application
    func fontFamilyForApplication()->String {
        
        var fontFamily:String? = AppConfiguration.sharedAppConfiguration.appFontFamily
        
        if fontFamily == nil {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                fontFamily = Constants.kSportsTemplateFontFamily
            }
            else {
                
                fontFamily = Constants.kEntertainmentTemplateFontFamily
            }
        }
        
        return fontFamily!
    }
}
