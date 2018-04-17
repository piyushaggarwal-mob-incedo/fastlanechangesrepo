//
//  ModuleLayoutCalculator+FetchRelativeFrame.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

extension ModuleLayoutCalculator {
    
    //MARK: Method to calculate module relative frame
    func calculateModuleRelativeFrame(relativeViewFrameDict:Dictionary<String, CGRect>, layoutDict:Dictionary<String, LayoutObject>) -> Dictionary<String, CGRect>{
        
        var moduleLayoutRelativeFrame:Dictionary<String, CGRect> = [:]
        
        if Constants.IPHONE {
            
            if let viewLayout = layoutDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"], let relativeViewFrame = relativeViewFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"]{
                
                let layoutFrame = Utility.initialiseViewLayout(viewLayout: viewLayout, relativeViewFrame: relativeViewFrame)
                moduleLayoutRelativeFrame["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = layoutFrame
            }
        }
        else {
            
            if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
                
                if let viewLayout = layoutDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"], let relativeViewFrame = relativeViewFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    let layoutFrame = Utility.initialiseViewLayout(viewLayout: viewLayout, relativeViewFrame: relativeViewFrame)
                    moduleLayoutRelativeFrame["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = layoutFrame
                }
            }
            else {
                
                if let viewLayout = layoutDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"], let relativeViewFrame = relativeViewFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    let layoutFrame = Utility.initialiseViewLayout(viewLayout: viewLayout, relativeViewFrame: relativeViewFrame)
                    moduleLayoutRelativeFrame["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = layoutFrame
                }
            }
        }
        
        return moduleLayoutRelativeFrame
    }
    
    
    //MARK: Method to calculate module height
    func calculateModuleLayoutHeight(componentRelativeFrameDict:Dictionary<String, CGRect>, resetHeightToZero:Bool) -> Dictionary<String, AnyObject>{
        
        var relativeFrameDict = componentRelativeFrameDict
        var heightDifferenceDict:Dictionary<String, CGFloat> = [:]
        
        if Constants.IPHONE {
            
            if var iPhoneFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                iPhoneFrame.size.height *= Utility.getBaseScreenHeightMultiplier()
                heightDifferenceDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = 0.0
                
                if resetHeightToZero {
  
                    heightDifferenceDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = 0.0 - iPhoneFrame.size.height
                    iPhoneFrame.size.height = 0.0
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = iPhoneFrame
            }
        }
        else {
            
            if var iPadLandscapeFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                iPadLandscapeFrame.size.height *= isScreenInLandscapeMode() == true ? Utility.getBaseScreenHeightMultiplier() : Utility.getBaseScreenWidthMultiplier()
                heightDifferenceDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = 0.0

                if resetHeightToZero {
                    
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = 0.0 - iPadLandscapeFrame.size.height
                    iPadLandscapeFrame.size.height = 0.0
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = iPadLandscapeFrame
            }
            
            if var iPadPortraitFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                iPadPortraitFrame.size.height *= isScreenInLandscapeMode() == true ? Utility.getBaseScreenWidthMultiplier() : Utility.getBaseScreenHeightMultiplier()
                heightDifferenceDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = 0.0

                if resetHeightToZero {
                    
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = 0.0 - iPadPortraitFrame.size.height
                    iPadPortraitFrame.size.height = 0.0
                }

                relativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = iPadPortraitFrame
            }
        }
        
        return [kComponentHeightDifference:heightDifferenceDict as AnyObject, kCurrentComponentRelativeFrameKeyName:relativeFrameDict as AnyObject]
    }
    
    //MARK: Method to calculate label height in module
    func calculateModuleLabelHeight(componentRelativeFrameDict:Dictionary<String, CGRect>, resetHeightToZero:Bool, labelObject:SFLabelObject, contentTitle:String?) -> Dictionary<String, AnyObject> {
        
        var relativeFrameDict = componentRelativeFrameDict
        var heightDifferenceDict:Dictionary<String, CGFloat> = [:]

        if Constants.IPHONE {
            
            if var iPhoneFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                if resetHeightToZero {
                    
                    heightDifferenceDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = 0.0 - iPhoneFrame.size.height
                    iPhoneFrame.size.height = 0.0
                }
                else {

                    let labelHeight = calculateLabelTextHeight(labelObject: labelObject, contentTitle: contentTitle!, labelWidth: iPhoneFrame.width * Utility.getBaseScreenWidthMultiplier())
                    heightDifferenceDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = labelHeight - iPhoneFrame.size.height
                    iPhoneFrame.size.height = labelHeight
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = iPhoneFrame
            }
        }
        else {
            
            if var iPadLandscapeFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                if resetHeightToZero {
                    
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = 0.0 - iPadLandscapeFrame.size.height
                    iPadLandscapeFrame.size.height = 0.0
                }
                else {
                    
                    let labelHeight = calculateLabelTextHeight(labelObject: labelObject, contentTitle: contentTitle!, labelWidth: iPadLandscapeFrame.width * Utility.getBaseScreenWidthMultiplier())
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = labelHeight - iPadLandscapeFrame.size.height
                    iPadLandscapeFrame.size.height = labelHeight
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = iPadLandscapeFrame
            }
            
            if var iPadPortraitFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                if resetHeightToZero {
                    
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = 0.0 - iPadPortraitFrame.size.height
                    iPadPortraitFrame.size.height = 0.0
                }
                else {
                    
                    let labelHeight = calculateLabelTextHeight(labelObject: labelObject, contentTitle: contentTitle!, labelWidth: iPadPortraitFrame.width * Utility.getBaseScreenWidthMultiplier())
                    heightDifferenceDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = labelHeight - iPadPortraitFrame.size.height
                    iPadPortraitFrame.size.height = labelHeight
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = iPadPortraitFrame
            }
        }
        return [kComponentHeightDifference:heightDifferenceDict as AnyObject, kCurrentComponentRelativeFrameKeyName:relativeFrameDict as AnyObject]
    }
    
    //MARK: Method to fetch font family for label
    private func fetchFontFamilyForLabel(labelObject:SFLabelObject) -> String? {
        
        var fontFamily:String?
        
        if labelObject.fontFamily != nil {
            
            if labelObject.fontWeight != nil {
                
                var fontWeight = (labelObject.fontWeight)!
                
                if fontWeight.lowercased() == "extrabold" && TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    fontWeight = "Black"
                }
                
                fontFamily = "\(Utility.sharedUtility.fontFamilyForApplication())-\(fontWeight)"
                
            }
            else {
                fontFamily = "\(Utility.sharedUtility.fontFamilyForApplication())"
            }
        }
        
        return fontFamily
    }
    
    //MARK: Method to get label text max height
    private func calculateLabelTextHeight(labelObject:SFLabelObject, contentTitle:String, labelWidth:CGFloat) -> CGFloat {
        
        var labelFont:UIFont?
        var labelFontSize:CGFloat?
        
        if let textFontSize = labelObject.textFontSize {
            
            labelFontSize = CGFloat(textFontSize) * Utility.getBaseScreenHeightMultiplier()
        }
        else {
            
            labelFontSize = UIFont.systemFontSize * Utility.getBaseScreenHeightMultiplier()
        }
        
        if let fontFamily = fetchFontFamilyForLabel(labelObject: labelObject) {
            
            labelFont = UIFont(name: fontFamily, size: labelFontSize!)
        }
        else {
            
            labelFont = UIFont.systemFont(ofSize: labelFontSize!)
        }
        
        let labelHeight = contentTitle.height(withConstraintWidth: labelWidth, withConstraintHeight: .greatestFiniteMagnitude, font: labelFont!)
        return labelHeight
    }
    
    //MARK: Method to calculate label height in module
    func calculateModuleYAxis(componentRelativeFrameDict:Dictionary<String, CGRect>, heightDifferenceDict:Dictionary<String, CGFloat>) -> Dictionary<String, CGRect> {
        
        var relativeFrameDict = componentRelativeFrameDict
        
        if Constants.IPHONE {
            
            if var iPhoneFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                if let heightDifference = heightDifferenceDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    iPhoneFrame.origin.y += heightDifference
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = iPhoneFrame
            }
        }
        else {
            
            if var iPadLandscapeFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                if let heightDifference = heightDifferenceDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {

                    iPadLandscapeFrame.origin.y += heightDifference
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = iPadLandscapeFrame
            }
            
            if var iPadPortraitFrame = componentRelativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                if let heightDifference = heightDifferenceDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {

                    iPadPortraitFrame.origin.y += heightDifference
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = iPadPortraitFrame
            }
        }
        
        return relativeFrameDict
    }
    
    //MARK: Method to calculate maximum height for module
    func calculateMaxYValue(currentMaxYDict:Dictionary<String, CGFloat>, currentComponentFrameDict:Dictionary<String, CGRect>) -> Dictionary<String, CGFloat> {
        
        var maxYDict = currentMaxYDict
        
        if Constants.IPHONE {
            
            if let iPhoneFrame = currentComponentFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                var maxYValue:CGFloat = iPhoneFrame.origin.y + iPhoneFrame.size.height
                
                if let maxY = maxYDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    if maxY > maxYValue {
                        
                        maxYValue = maxY
                    }
                }
                
                maxYDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = maxYValue
            }
        }
        else {
            
            if let iPadLandscapeFrame = currentComponentFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                var maxYValue:CGFloat = iPadLandscapeFrame.origin.y + iPadLandscapeFrame.size.height
                
                if let maxY = maxYDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                    
                    if maxY > maxYValue {
                        
                        maxYValue = maxY
                    }
                }
                
                maxYDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = maxYValue
            }
            
            if let iPadPortraitFrame = currentComponentFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                var maxYValue:CGFloat = iPadPortraitFrame.origin.y + iPadPortraitFrame.size.height
                
                if let maxY = maxYDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                    
                    if maxY > maxYValue {
                        
                        maxYValue = maxY
                    }
                }
                
                maxYDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = maxYValue
            }
        }
        
        return maxYDict
    }
    
    //MARK: Method to update module layout height
    func updateModuleLayoutHeight(maxHeight:Dictionary<String, CGFloat>, currentComponentFrameDict:Dictionary<String, CGRect>, margin:CGFloat) -> Dictionary<String, CGRect> {
        
        var relativeFrameDict = currentComponentFrameDict
        
        if Constants.IPHONE {
            
            if var iPhoneFrame = currentComponentFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                if let maxHeight = maxHeight["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    iPhoneFrame.size.height = maxHeight + margin
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = iPhoneFrame
            }
        }
        else {
            
            if var iPadLandscapeFrame = currentComponentFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                if let maxHeight = maxHeight["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                    
                    iPadLandscapeFrame.size.height = maxHeight + margin
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = iPadLandscapeFrame
            }
            
            if var iPadPortraitFrame = currentComponentFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                if let maxHeight = maxHeight["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                    
                    iPadPortraitFrame.size.height = maxHeight + margin
                }
                
                relativeFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = iPadPortraitFrame
            }
        }
        
        return relativeFrameDict
    }
    
    //MARK: Method to add height
    func updateModuleLayoutHeight(gridHeight:Dictionary<String, CGFloat>, moduleHeight:Dictionary<String, CGFloat>, marginHeight:CGFloat) -> Dictionary<String, CGFloat> {
        
        var gridHeightDict = gridHeight
        
        if Constants.IPHONE {
            
            if var gridHeight = gridHeight["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    gridHeight += moduleHeight
                }
                else if marginHeight > 0 {
                    
                    gridHeight += marginHeight
                }
                
                gridHeightDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = gridHeight
            }
            else {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] {
                    
                    gridHeightDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = moduleHeight
                }
            }
        }
        else {
            
            if var gridHeight = gridHeight["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                    
                    gridHeight += moduleHeight
                }
                else if marginHeight > 0 {
                    
                    gridHeight += marginHeight
                }
                
                gridHeightDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = gridHeight
            }
            else {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] {
                    
                    gridHeightDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = moduleHeight
                }
            }
            
            if var gridHeight = gridHeight["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                    
                    gridHeight += moduleHeight
                }
                else if marginHeight > 0 {
                    
                    gridHeight += marginHeight
                }
                
                gridHeightDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = gridHeight
            }
            else {
                
                if let moduleHeight = moduleHeight["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] {
                    
                    gridHeightDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = moduleHeight
                }
            }
        }
        
        return gridHeightDict
    }
    
    //MARK: Method to check if device is in landscape mode or portrait mode
    func isScreenInLandscapeMode() -> Bool {
        
        if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
            
            return true
        }
        else {
            
            return false
        }
    }
}
