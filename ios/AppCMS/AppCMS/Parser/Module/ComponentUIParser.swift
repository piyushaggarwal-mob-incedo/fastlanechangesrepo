//
//  ComponentUIParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 03/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ComponentUIParser: NSObject {

    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" || typeOfModule == "imageView"
            {
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "pageControl"
            {
                let pageControlParser = SFPageControlParser()
                let pageControlObject = pageControlParser.parsePageControlJson(pageControlDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(pageControlObject)
            }
            else if typeOfModule == "carousel" {
                
                let carouselParser = SFCarouselParser()
                let carouselObject = carouselParser.parseCarouselJson(carouselDict: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(carouselObject)
            }
            else if typeOfModule == "textfield"
            {
                let textFieldParser = SFTextFieldParser()
                let textFieldObject = textFieldParser.parseTextFieldJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textFieldObject)
            }
            else if typeOfModule == "AC SegmentedView"
            {
                let segmentViewParser = SFSegmentViewParser()
                let segmentViewobject = segmentViewParser.parseSegmentViewJson(segmentViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(segmentViewobject)
            }
            else if typeOfModule == "dropDown"
            {
                #if os(iOS)
                    let dropDownParser = SFDropDownParser()
                    let dropDownObject = dropDownParser.parseDropdDownJson(dropDownDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(dropDownObject)
                #endif
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                let progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(progressViewObject)
            }
            else if typeOfModule == "starRatingView"
            {
                let starRatingParser = SFStarRatingParser()
                let starRatingObject = starRatingParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(starRatingObject)
            }
            else if typeOfModule == "castView" {
                
                let castViewParser = SFCastViewParser()
                let castViewObject = castViewParser.parseCastViewJson(castViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(castViewObject)
            }
            else if typeOfModule == "headerView"
            {
                #if os(tvOS)
                    let headerViewParser = SFHeaderViewParser()
                    let headerViewObject = headerViewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(headerViewObject)
                #endif
            }
            else if typeOfModule == "pageControl"
            {
                let pageControlParser = SFPageControlParser()
                let pageControlObject = pageControlParser.parsePageControlJson(pageControlDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(pageControlObject)
            }
            else if typeOfModule == "actionLabel" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "collectionGrid" {
                let colletionGridParser = SFCollectionGridParser()
                let collectionGridObject = colletionGridParser.parseCollectionGridJson(collectionGridDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(collectionGridObject)
            }
            else if typeOfModule == "tableView" {
                
                let tableViewParser = SFTableViewParser()
                let tableViewObject = tableViewParser.parseTableViewJson(tableViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(tableViewObject)
            }
            else if typeOfModule == "planMetaDataView" {
                
                let planMetaDataViewParser = SFPlanMetaDataViewParser()
                let planMetaDataViewObject = planMetaDataViewParser.parsePlanMetaDataViewJson(planMetaDataViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(planMetaDataViewObject)
            }
            else if typeOfModule == "AC Login Component" || typeOfModule == "AC Create Login Component" || typeOfModule == "AC SignUp Component" || typeOfModule == "AC SignUp 01"
            {
                let loginComponentUIParser = LoginComponentUIParser()
                let loginObject = loginComponentUIParser.parseLoginComponentJson(loginComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(loginObject)
            }
            else if typeOfModule == "AC Settings Account 01"
            {
                #if os(iOS)
                let componentKey: String = moduleDictionary["key"] as? String ?? ""
                if componentKey == "subscriptionInfo"
                {
                    if AppConfiguration.sharedAppConfiguration.serviceType == .SVOD
                    {
                        let userDetailCompParser = UserComponentDetailParser()
                        let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        componentArray.append(userDetailCompObject)
                    }
                    else
                    {
                        continue
                    }
                }
                else if componentKey == "download"
                {
                    if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil
                    {
                        if AppConfiguration.sharedAppConfiguration.isDownloadEnabled == true {
                            
                            let userDetailCompParser = UserComponentDetailParser()
                            let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                            componentArray.append(userDetailCompObject)
                        }
                        else {
                            
                            continue
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                else
                {
                    let userDetailCompParser = UserComponentDetailParser()
                    let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(userDetailCompObject)
                }
                #endif
            }
            else if typeOfModule == "toggle"
            {
                #if os(iOS)
                let toggleViewParser = SFToggleParser()
                let toggleObject = toggleViewParser.parseToggleJson(toggleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(toggleObject)
                #endif
            }
            else if typeOfModule == "AC SeasonTray 01"
            {
                let trayParser = SFTrayParser()
                let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if trayObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(trayObject)
                }
            }
            else if typeOfModule == "AC Episode Module"
            {
                let trayParser = SFTrayParser()
                let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if trayObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(trayObject)
                }
            }
            else if typeOfModule == "AC SegmentedView"
            {
                let segmentViewParser = SFSegmentViewParser()
                let segmentViewobject = segmentViewParser.parseSegmentViewJson(segmentViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(segmentViewobject)
            }
            else if typeOfModule == "carouselItem"
            {
                let carouselItemObject = SFCarouselItemParser().parseCarouselItem(carouselObjectDictionary: moduleDictionary)
                componentArray.append(carouselItemObject)
            }
            else if typeOfModule == "webView"
            {
                #if os(iOS)
                    let webViewParser = SFWebViewParser()
                    let webViewObject = webViewParser.parseWebViewJson(webViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(webViewObject)
                #endif
            }
            else if typeOfModule == "dropDownButton" {
                
                #if os(iOS)
                    let dropdownParser = SFDropDownButtonParser()
                    let dropDownObject = dropdownParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(dropDownObject)
                #endif
            }
            else if typeOfModule == "adView" {
                
                #if os(iOS)
                    let adViewParser = SFAdViewParser()
                    let adViewObject = adViewParser.parseAdViewModuleJson(adViewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    
                    if adViewObject.layoutObjectDict.isEmpty == false {
                        
                        componentArray.append(adViewObject)
                    }
                #endif
            }
            else if typeOfModule == "thumbnailInfoView" {
                
                #if os(iOS)
                    let verticalArticleMetadataParser = SFVerticalArticleMetadataParser()
                    let verticalArticleMetadataObject = verticalArticleMetadataParser.parseVerticalArticalMetadataJson(verticalArticalMetadataDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    
                    if verticalArticleMetadataObject.layoutObjectDict.isEmpty == false {
                        
                        componentArray.append(verticalArticleMetadataObject)
                    }
                #endif
            }
        }
        
        return componentArray
    }
}
