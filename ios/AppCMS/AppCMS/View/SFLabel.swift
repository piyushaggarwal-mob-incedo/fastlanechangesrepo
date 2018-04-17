//
//  SFLabel.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFLabel: UILabel {

    var labelObject:SFLabelObject?
    var relativeViewFrame:CGRect?
    var labelLayout:LayoutObject?
    
    #if os(tvOS)
    private var _shouldGetFocused: Bool = false
    
    var shouldGetFocused: Bool {
        set (newSetter) {
            _shouldGetFocused = newSetter
            self.setNeedsFocusUpdate()
        }
        get {
            return _shouldGetFocused
        }
    }
    #endif
    
    func initialiseLabelFrameFromLayout(labelLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: labelLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createLabelView() -> Void {
        
        if ((labelObject?.backgroundColor) != nil) {
            
            if let backgroundAlpha = labelObject?.backgroundColorAlpha {
                self.backgroundColor = Utility.hexStringToUIColor(hex: (labelObject?.backgroundColor)!).withAlphaComponent(CGFloat(backgroundAlpha))
            } else {
                self.backgroundColor = Utility.hexStringToUIColor(hex: (labelObject?.backgroundColor)!)
            }
        }
        else {
            
            self.backgroundColor = UIColor.clear
        }
        #if os(iOS)
            if labelObject?.textColor != nil {
                
                self.textColor = Utility.hexStringToUIColor(hex: (labelObject?.textColor)!)
            }
            else {
                self.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "000000")
            }
        #else
            self.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "000000")
        #endif
        
        if ((labelObject?.borderColor) != nil) {
            
            self.layer.borderColor = Utility.hexStringToUIColor(hex: (labelObject?.borderColor)!).cgColor
        }
        
        if ((labelObject?.borderWidth) != nil) {
            
            self.layer.borderWidth = CGFloat((labelObject?.borderWidth)!)
        }
        
        if labelObject?.cornerRadius != nil {
            
            self.layer.cornerRadius = CGFloat((labelObject?.cornerRadius)!)
        }
        
        #if os(tvOS)
        if let letterSpacing = labelObject?.letterSpacing {
            self.addTextSpacing(spacing: letterSpacing)
        }
        #endif
        
        if labelLayout?.numberOfLines != nil {
            
            self.numberOfLines = (labelLayout?.numberOfLines)!
        }
        else {
            
            if labelObject?.numberOfLines != nil {
                
                self.numberOfLines = (labelObject?.numberOfLines)!
            }
        }
        
        if labelObject?.alpha != nil {
            
            self.alpha = CGFloat((labelObject?.alpha)!)
        }
        
        var fontSize:Float?
        
        if labelLayout?.fontSize != nil {
            fontSize = labelLayout?.fontSize
        }
        else if labelObject?.textFontSize != nil {
            fontSize = labelObject?.textFontSize
        }
        
        var fontFamily:String?
        
        if labelObject?.fontFamily != nil {
            
            if labelObject?.fontWeight != nil {
                
                var fontWeight = (labelObject?.fontWeight)!
                
                if fontWeight.lowercased() == "extrabold" && TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    fontWeight = "Black"
                }
                
                fontFamily = "\(Utility.sharedUtility.fontFamilyForApplication())-\(fontWeight)"
                
            }
            else {
                fontFamily = "\(Utility.sharedUtility.fontFamilyForApplication())"
            }
        }
        
        if fontFamily != nil && fontSize != nil {
            
            self.font = UIFont(name: fontFamily!, size: CGFloat(fontSize!))
        }
        
        if labelObject?.textAlignment != nil {
            
            switch (labelObject?.textAlignment)! {
            case "center":
                self.textAlignment = .center
            case "left":
                self.textAlignment = .left
            case "right":
                self.textAlignment = .right
            default:
                self.textAlignment = .left
            }
        }
    }
    
    func hugContent() {
        
        #if os(iOS)
            self.changeFrameWidth(width: self.intrinsicContentSize.width + 10)
        #else
            self.changeFrameWidth(width: self.intrinsicContentSize.width + 20)
        #endif

        self.textAlignment = .center
    }
    
    #if os(tvOS)
    override var canBecomeFocused: Bool {
        return _shouldGetFocused
    }
    #endif
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
