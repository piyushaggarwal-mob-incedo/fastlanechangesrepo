
//
//  ModuleLayoutCalculator.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class ModuleLayoutCalculator: NSObject {

    //Constants Created for Dictionary key names
    let kPreviousComponentRelativeFrameKeyName = "previousComponentRelativeFrame"
    let kCurrentComponentRelativeFrameKeyName = "currentComponentRelativeFrame"
    let kComponentHeightDifference = "componentHeightDifference"
    
    //MARK: Method to fetch layout details for Module
    func fetchLayoutDetailsForModule(pageAPIModuleObject: SFModuleObject, moduleUIObject:AnyObject, relativeViewFrameDict:Dictionary<String, CGRect>) -> Dictionary<String, AnyObject>{
        
        var moduleLayoutDetailsDict:Dictionary<String, AnyObject> = [:]
        
        if pageAPIModuleObject.moduleData != nil && ((pageAPIModuleObject.moduleData?.count)! > 0) {
            
            if moduleUIObject is SFVerticalArticleViewObject {
                
                let moduleObject = moduleUIObject as! SFVerticalArticleViewObject
                let moduleRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict, layoutDict: moduleObject.layoutObjectDict)
                let moduleLayoutDetails = fetchLayoutDetailsForVerticalArticleModule(pageAPIModuleObject: pageAPIModuleObject, verticalArticleViewObject: moduleObject, relativeViewFrameDict: moduleRelativeFrameDict)
                
                moduleLayoutDetailsDict["\(moduleObject.key ?? "")"] = moduleLayoutDetails as AnyObject
            }
        }
        
        return moduleLayoutDetailsDict
    }
    
    //MARK: Method to fetch layout details for vertical article view
    private func fetchLayoutDetailsForVerticalArticleModule(pageAPIModuleObject:SFModuleObject, verticalArticleViewObject:SFVerticalArticleViewObject, relativeViewFrameDict:Dictionary<String, CGRect>) -> Dictionary<String, AnyObject> {
        
        var gridObjectComponents:Array<Dictionary<String, AnyObject>> = []
        var gridHeight:Dictionary<String, CGFloat> = [:]
        for component in verticalArticleViewObject.components {
            
            if component is SFCollectionGridObject {
                
                let collectionGridObject:SFCollectionGridObject = component as! SFCollectionGridObject
                let componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict, layoutDict: collectionGridObject.layoutObjectDict)
                let gridLayoutDetails = fetchLayoutDetailsForCollectionGrid(pageAPIModuleObject: pageAPIModuleObject, collectionGridObject: collectionGridObject, relativeViewFrameDict: componentRelativeFrameDict, moduleObject: verticalArticleViewObject as AnyObject)
                
                if let collectionGridLayoutDetails = gridLayoutDetails["\(collectionGridObject.key ?? "")"] {
                    
                    if collectionGridLayoutDetails["gridHeight"] is Dictionary<String, CGFloat> {
                        
                        gridHeight = collectionGridLayoutDetails["gridHeight"] as! Dictionary<String, CGFloat>
                    }
                }
                gridObjectComponents.append(gridLayoutDetails)
            }
        }
        
        var updatedRelativeViewFrameDict = relativeViewFrameDict
        
        if gridHeight.isEmpty == false {
            
            updatedRelativeViewFrameDict = updateModuleLayoutHeight(maxHeight: gridHeight, currentComponentFrameDict: updatedRelativeViewFrameDict, margin: 0.0)
        }
        return [kCurrentComponentRelativeFrameKeyName:updatedRelativeViewFrameDict as AnyObject, "components":gridObjectComponents as AnyObject]
    }
    
    //MARK: Method to fetch layout details for collection grid
    private func fetchLayoutDetailsForCollectionGrid(pageAPIModuleObject:SFModuleObject, collectionGridObject:SFCollectionGridObject, relativeViewFrameDict:Dictionary<String, CGRect>, moduleObject:AnyObject) -> Dictionary<String, AnyObject>{
        
        //TODO: Need to update the logic to reduce iterations
        var gridObjectComponents:Array<Dictionary<String, AnyObject>> = []
        var gridHeight:Dictionary<String, CGFloat> = [:]
        for gridObject in (pageAPIModuleObject.moduleData)! {
            
            if gridObject is SFGridObject {
        
                var gridRelativeFrameDict:Dictionary<String, AnyObject> = [:]
                var maxYValueDict:Dictionary<String, CGFloat> = [:]
                for component in collectionGridObject.trayComponents {
                    
                    let updatedRelativeFrameDict = fetchLayoutDetailsForSubComponents(gridObject: gridObject as! SFGridObject, subComponent: component as AnyObject, relativeViewFrameDict: relativeViewFrameDict, componentHeightDiffDict: [:], moduleObject: moduleObject, maxYValueDict: maxYValueDict)
                    
                    let keyName:String = updatedRelativeFrameDict["keyName"] as! String
                    
                    gridRelativeFrameDict[keyName] = updatedRelativeFrameDict["value"] as AnyObject
                    maxYValueDict = updatedRelativeFrameDict["maxYValue"] as! Dictionary<String, CGFloat>
                }
                
                gridRelativeFrameDict["gridWidth"] = maxYValueDict as AnyObject
                gridObjectComponents.append(gridRelativeFrameDict)
                gridHeight = updateModuleLayoutHeight(gridHeight: gridHeight, moduleHeight: maxYValueDict, marginHeight: 0)
            }
        }

        var gridLayoutDetails:Dictionary<String, AnyObject> = [kCurrentComponentRelativeFrameKeyName: relativeViewFrameDict as AnyObject]
        if gridObjectComponents.count > 0 {
            
            gridLayoutDetails["components"] = gridObjectComponents as AnyObject
        }
        
        var totalAdHeight:Float = 90.0
        if moduleObject is SFVerticalArticleViewObject {
            
            var adDisplayFrequency = 0
            
            if let adDisplayFrequencyValue = (moduleObject as! SFVerticalArticleViewObject).settings?.adDisplayFrequency {
                
                adDisplayFrequency = adDisplayFrequencyValue
            }
            
            let noOfAdsToBeDisplayed = (pageAPIModuleObject.moduleData?.count ?? 0) / adDisplayFrequency
            
            totalAdHeight *= Float(noOfAdsToBeDisplayed)
            print("\(noOfAdsToBeDisplayed)")
        }
        
        let additionalGridHeight = ((collectionGridObject.trayPadding ?? 0 ) * Float(pageAPIModuleObject.moduleData?.count ?? 0)) + totalAdHeight
        
        gridHeight = updateModuleLayoutHeight(gridHeight: gridHeight, moduleHeight: [:], marginHeight: CGFloat(additionalGridHeight))

        if gridHeight.isEmpty == false {

            let componentRelativeFrameDict = updateModuleLayoutHeight(maxHeight: gridHeight, currentComponentFrameDict: gridLayoutDetails[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, margin: 0.0)
            gridLayoutDetails[kCurrentComponentRelativeFrameKeyName] = componentRelativeFrameDict as AnyObject
        }
        
        gridLayoutDetails["gridHeight"] = gridHeight as AnyObject
        return ["\(collectionGridObject.key ?? "")": gridLayoutDetails as AnyObject]
    }
    
    //MARK: Method to fetch layout details for sub components
    private func fetchLayoutDetailsForSubComponents(gridObject:SFGridObject, subComponent:AnyObject, relativeViewFrameDict:Dictionary<String, CGRect>, componentHeightDiffDict:Dictionary<String, CGFloat>, moduleObject:AnyObject, maxYValueDict:Dictionary<String, CGFloat>) -> Dictionary<String, AnyObject> {
        
        var componentHeightDifferenceDict:Dictionary<String, CGFloat> = componentHeightDiffDict
        var subComponentLayoutDetails:Dictionary<String, AnyObject> = [:]
        var keyName:String = ""
        var maxYDict:Dictionary<String, CGFloat> = maxYValueDict
        if subComponent is SFImageObject {
            
            let imageObject = subComponent as! SFImageObject
            subComponentLayoutDetails = fetchLayoutDetailsForImage(gridObject: gridObject, imageViewObject: imageObject, relativeViewFrameDict: [kCurrentComponentRelativeFrameKeyName:relativeViewFrameDict as AnyObject, kComponentHeightDifference : componentHeightDifferenceDict as AnyObject], moduleObject: moduleObject)
            keyName = imageObject.key ?? ""
            let updatedRelativeViewFrameDict = subComponentLayoutDetails["\(imageObject.key ?? "")"] as! Dictionary<String, AnyObject>
            componentHeightDifferenceDict = updatedRelativeViewFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            
            maxYDict = calculateMaxYValue(currentMaxYDict: maxYDict, currentComponentFrameDict: updatedRelativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>)
        }
        else if subComponent is SFVerticalArticleMetadataObject {
            
            let metadataObject = subComponent as! SFVerticalArticleMetadataObject
            subComponentLayoutDetails = fetchLayoutDetailsForVerticalArticleThumbnailInfo(gridObject: gridObject, verticalArticleThumbnailMetadata: metadataObject, relativeViewFrameDict: [kCurrentComponentRelativeFrameKeyName:relativeViewFrameDict as AnyObject, kComponentHeightDifference : componentHeightDifferenceDict as AnyObject], moduleObject: moduleObject)
            keyName = metadataObject.key ?? ""
            let updatedRelativeViewFrameDict = subComponentLayoutDetails["\(metadataObject.key ?? "")"] as! Dictionary<String, AnyObject>
            componentHeightDifferenceDict = updatedRelativeViewFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            
            maxYDict = calculateMaxYValue(currentMaxYDict: maxYDict, currentComponentFrameDict: updatedRelativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>)
        }
        else if subComponent is SFLabelObject {
            
            let labelObject = subComponent as! SFLabelObject
            subComponentLayoutDetails = fetchLayoutDetailsForLabel(gridObject: gridObject, labelObject: labelObject, relativeViewFrameDict: [kCurrentComponentRelativeFrameKeyName:relativeViewFrameDict as AnyObject, kComponentHeightDifference : componentHeightDifferenceDict as AnyObject], moduleObject: moduleObject)
            keyName = labelObject.key ?? ""

            let updatedRelativeViewFrameDict = subComponentLayoutDetails["\(labelObject.key ?? "")"] as! Dictionary<String, AnyObject>
            
            if updatedRelativeViewFrameDict[kComponentHeightDifference] is Dictionary<String, CGFloat> {
                
                componentHeightDifferenceDict = updatedRelativeViewFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            }
            else {
                
                componentHeightDifferenceDict = [:]
            }
            
            maxYDict = calculateMaxYValue(currentMaxYDict: maxYDict, currentComponentFrameDict: updatedRelativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>)
        }
        else if subComponent is SFButtonObject {
            
            let buttonObject = subComponent as! SFButtonObject
            keyName = buttonObject.key ?? ""

            subComponentLayoutDetails = fetchLayoutDetailsForButton(gridObject: gridObject, buttonObject: buttonObject, relativeViewFrameDict: [kCurrentComponentRelativeFrameKeyName:relativeViewFrameDict as AnyObject, kComponentHeightDifference : componentHeightDifferenceDict as AnyObject], moduleObject: moduleObject)
            
            let updatedRelativeViewFrameDict = subComponentLayoutDetails["\(buttonObject.key ?? "")"] as! Dictionary<String, AnyObject>
            componentHeightDifferenceDict = updatedRelativeViewFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            
            maxYDict = calculateMaxYValue(currentMaxYDict: maxYDict, currentComponentFrameDict: updatedRelativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>)
        }
        else if subComponent is SFSeparatorViewObject {
            
            let seperatorViewObject = subComponent as! SFSeparatorViewObject
            keyName = seperatorViewObject.key ?? ""

            subComponentLayoutDetails = fetchLayoutDetailsForSeparatorView(separatorViewObject: seperatorViewObject, relativeViewFrameDict: [kCurrentComponentRelativeFrameKeyName:relativeViewFrameDict as AnyObject, kComponentHeightDifference : componentHeightDifferenceDict as AnyObject], moduleObject: moduleObject)
            
            let updatedRelativeViewFrameDict = subComponentLayoutDetails["\(seperatorViewObject.key ?? "")"] as! Dictionary<String, AnyObject>
            componentHeightDifferenceDict = updatedRelativeViewFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            
            maxYDict = calculateMaxYValue(currentMaxYDict: maxYDict, currentComponentFrameDict: updatedRelativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>)
        }
        
        return ["keyName": keyName as AnyObject, "value": subComponentLayoutDetails["\(keyName)"] as AnyObject, kComponentHeightDifference:componentHeightDifferenceDict as AnyObject, "maxYValue":maxYDict as AnyObject]
    }
    
    //MARK: Method to fetch layout details for vertical article thumbnail info view
    private func fetchLayoutDetailsForVerticalArticleThumbnailInfo(gridObject:SFGridObject, verticalArticleThumbnailMetadata:SFVerticalArticleMetadataObject, relativeViewFrameDict:Dictionary<String, AnyObject>, moduleObject:AnyObject) -> Dictionary<String, AnyObject> {
        
        let componentHeightDifferenceDict = relativeViewFrameDict[kComponentHeightDifference] as? Dictionary<String, CGFloat>
        var componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, layoutDict: verticalArticleThumbnailMetadata.layoutObjectDict)
        
        var previousComponentHeightDifference:Dictionary<String,CGFloat> = [:]
        var gridRelativeFrameDict:Dictionary<String, AnyObject> = [:]

        var maxYValueDict:Dictionary<String, CGFloat> = [:]
        for component in verticalArticleThumbnailMetadata.components {
            
            let subComponentRelativeFrameDict = fetchLayoutDetailsForSubComponents(gridObject: gridObject, subComponent: component as AnyObject, relativeViewFrameDict: componentRelativeFrameDict, componentHeightDiffDict: previousComponentHeightDifference, moduleObject: moduleObject, maxYValueDict: maxYValueDict)
            
            let keyName:String = subComponentRelativeFrameDict["keyName"] as! String
            gridRelativeFrameDict[keyName] = subComponentRelativeFrameDict["value"] as AnyObject
            
            previousComponentHeightDifference = subComponentRelativeFrameDict[kComponentHeightDifference] as! Dictionary<String, CGFloat>
            maxYValueDict = subComponentRelativeFrameDict["maxYValue"] as! Dictionary<String, CGFloat>
        }
        
        previousComponentHeightDifference.removeAll()
        
        if componentHeightDifferenceDict != nil {
            
            componentRelativeFrameDict = calculateModuleYAxis(componentRelativeFrameDict: componentRelativeFrameDict, heightDifferenceDict: componentHeightDifferenceDict!)
        }
        
        if maxYValueDict.isEmpty == false {
            
            componentRelativeFrameDict = updateModuleLayoutHeight(maxHeight: maxYValueDict, currentComponentFrameDict: componentRelativeFrameDict, margin: 10.0)
        }
        
        var componentLayoutDetails = [kCurrentComponentRelativeFrameKeyName:componentRelativeFrameDict as AnyObject, kComponentHeightDifference:[:] as AnyObject]

        if gridRelativeFrameDict.count > 0 {
            
            componentLayoutDetails["components"] = gridRelativeFrameDict as AnyObject
        }
        
        return ["\(verticalArticleThumbnailMetadata.key ?? "")" : componentLayoutDetails as AnyObject]
    }
    
    //MARK: Method to fetch layout details for image view
    private func fetchLayoutDetailsForImage(gridObject:SFGridObject, imageViewObject:SFImageObject, relativeViewFrameDict:Dictionary<String, AnyObject>, moduleObject:AnyObject) -> Dictionary<String, AnyObject> {
        
        let componentHeightDifferenceDict = relativeViewFrameDict[kComponentHeightDifference] as? Dictionary<String, CGFloat>
        var componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, layoutDict: imageViewObject.layoutObjectDict)
        
        var tempRelativeFrameDict:Dictionary<String, AnyObject> = [:]
        if imageViewObject.key == "thumbnailImage" {
            
            if let _ = getImageUrlFromArray(imageFetchType: .VideoImage, gridObject: gridObject) {
                
                tempRelativeFrameDict = calculateModuleLayoutHeight(componentRelativeFrameDict: componentRelativeFrameDict, resetHeightToZero: false)
            }
            else {
                
                tempRelativeFrameDict = calculateModuleLayoutHeight(componentRelativeFrameDict: componentRelativeFrameDict, resetHeightToZero: true)
            }
        }
        else if imageViewObject.key == "badgeImage" {
            
            if let _ = getImageUrlFromArray(imageFetchType: .BadgeImage, gridObject: gridObject) {
                
                tempRelativeFrameDict = calculateModuleLayoutHeight(componentRelativeFrameDict: componentRelativeFrameDict, resetHeightToZero: false)
            }
            else {
                
                tempRelativeFrameDict = calculateModuleLayoutHeight(componentRelativeFrameDict: componentRelativeFrameDict, resetHeightToZero: true)
            }
        }
        
        if tempRelativeFrameDict[kCurrentComponentRelativeFrameKeyName] != nil {
            
            componentRelativeFrameDict = tempRelativeFrameDict[kCurrentComponentRelativeFrameKeyName] as! [String : CGRect]
        }
        
        if componentHeightDifferenceDict != nil {
            
            componentRelativeFrameDict = calculateModuleYAxis(componentRelativeFrameDict: componentRelativeFrameDict, heightDifferenceDict: componentHeightDifferenceDict!)
        }
        
        let componentLayoutDetails = [kCurrentComponentRelativeFrameKeyName:componentRelativeFrameDict as AnyObject, kComponentHeightDifference:tempRelativeFrameDict[kComponentHeightDifference] as AnyObject]

        return ["\(imageViewObject.key ?? "")" : componentLayoutDetails as AnyObject]
    }
    
    //MARK: Method to get image url from images array
    private func getImageUrlFromArray(imageFetchType:ImageFetchType, gridObject:SFGridObject) -> String? {
        
        var imageUrl:String?
        
        for image in gridObject.images {
            
            let imageObj: SFImage = image as! SFImage
            
            if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                
                if imageFetchType == .BadgeImage {
                    
                    imageUrl = imageObj.badgeImageUrl
                }
                else if imageFetchType == .VideoImage {
                    
                    imageUrl = imageObj.imageSource
                }
                break
            }
        }
        
        return imageUrl
    }
    
    //MARK: Method to fetch layout details for label
    private func fetchLayoutDetailsForLabel(gridObject:SFGridObject, labelObject:SFLabelObject, relativeViewFrameDict:Dictionary<String, AnyObject>, moduleObject:AnyObject) -> Dictionary<String, AnyObject> {
        
        let componentHeightDifferenceDict = relativeViewFrameDict[kComponentHeightDifference] as? Dictionary<String, CGFloat>
        var componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, layoutDict: labelObject.layoutObjectDict)
        var tempRelativeFrameDict:Dictionary<String, AnyObject> = [:]

        var labelString:String?
        var shouldUpdateRelativeFrame:Bool = false
        var resetHeightToZero:Bool = false
        
        if labelObject.key == "title" {
            
            if let contentTitle = gridObject.contentTitle {
                
                labelString = contentTitle
                resetHeightToZero = false
            }
            else {
                
                resetHeightToZero = true
            }
            
            shouldUpdateRelativeFrame = true
        }
        else if labelObject.key == "subTitle" {
            
            var shouldDisplaySubtitle = true
            
            if moduleObject is SFVerticalArticleViewObject {
                
                if let displaySubHeading = (moduleObject as! SFVerticalArticleViewObject).settings?.displaySubHeading {
                    
                    shouldDisplaySubtitle = displaySubHeading
                }
            }
            
            if let contentSubTitle = gridObject.contentDescription, shouldDisplaySubtitle == true {
                
                labelString = contentSubTitle
                resetHeightToZero = false
            }
            else {
                
                resetHeightToZero = true
            }
            
            shouldUpdateRelativeFrame = true
        }
        else if labelObject.key == "description" {
            
            if let contentDescription = gridObject.contentDescription {
                
                labelString = contentDescription
                resetHeightToZero = false
            }
            else {
                
                resetHeightToZero = true
            }
            
            shouldUpdateRelativeFrame = true
        }
        
        if shouldUpdateRelativeFrame {
            
            tempRelativeFrameDict = calculateModuleLabelHeight(componentRelativeFrameDict: componentRelativeFrameDict, resetHeightToZero: resetHeightToZero, labelObject: labelObject, contentTitle: labelString)
        }
        
        if tempRelativeFrameDict[kCurrentComponentRelativeFrameKeyName] != nil {
            
            componentRelativeFrameDict = tempRelativeFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>
        }
        
        if componentHeightDifferenceDict != nil {
            
            componentRelativeFrameDict = calculateModuleYAxis(componentRelativeFrameDict: componentRelativeFrameDict, heightDifferenceDict: componentHeightDifferenceDict!)
        }
        
        let componentLayoutDetails = [kCurrentComponentRelativeFrameKeyName:componentRelativeFrameDict as AnyObject, kComponentHeightDifference:tempRelativeFrameDict[kComponentHeightDifference] as AnyObject]
        return ["\(labelObject.key ?? "")":componentLayoutDetails as AnyObject]
    }
    
    
    //MARK: Method to fetch layout details for button
    private func fetchLayoutDetailsForButton(gridObject:SFGridObject, buttonObject:SFButtonObject, relativeViewFrameDict:Dictionary<String, AnyObject>, moduleObject:AnyObject) -> Dictionary<String, AnyObject> {
        
        let componentHeightDifferenceDict = relativeViewFrameDict[kComponentHeightDifference] as? Dictionary<String, CGFloat>
        var componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, layoutDict: buttonObject.layoutObjectDict)
        
        if componentHeightDifferenceDict != nil {

            componentRelativeFrameDict = calculateModuleYAxis(componentRelativeFrameDict: componentRelativeFrameDict, heightDifferenceDict: componentHeightDifferenceDict!)
        }
        
        let componentLayoutDetails = [kCurrentComponentRelativeFrameKeyName:componentRelativeFrameDict as AnyObject, kComponentHeightDifference:[:] as AnyObject]

        return ["\(buttonObject.key ?? "")":componentLayoutDetails as AnyObject]
    }
    
    //MARK: Method to fetch layout details for separator view
    private func fetchLayoutDetailsForSeparatorView(separatorViewObject:SFSeparatorViewObject, relativeViewFrameDict:Dictionary<String, AnyObject>, moduleObject:AnyObject) -> Dictionary<String, AnyObject> {
        
        let componentHeightDifferenceDict = relativeViewFrameDict[kComponentHeightDifference] as? Dictionary<String, CGFloat>
        var componentRelativeFrameDict = calculateModuleRelativeFrame(relativeViewFrameDict: relativeViewFrameDict[kCurrentComponentRelativeFrameKeyName] as! Dictionary<String, CGRect>, layoutDict: separatorViewObject.layoutObjectDict)
        
        if componentHeightDifferenceDict != nil {
            
            componentRelativeFrameDict = calculateModuleYAxis(componentRelativeFrameDict: componentRelativeFrameDict, heightDifferenceDict: componentHeightDifferenceDict!)
        }
        
        let componentLayoutDetails = [kCurrentComponentRelativeFrameKeyName:componentRelativeFrameDict as AnyObject, kComponentHeightDifference:[:] as AnyObject]

        return ["\(separatorViewObject.key ?? "")":componentLayoutDetails as AnyObject]
    }
}

