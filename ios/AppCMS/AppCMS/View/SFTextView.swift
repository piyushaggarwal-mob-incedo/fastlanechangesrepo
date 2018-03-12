//
//  SFTextView.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFTextView: UITextView {
    
    var textViewText:String?
    var textViewObject:SFTextViewObject?
    var textViewLayout:LayoutObject?
    var relativeViewFrame:CGRect?

    func initialiseTextViewFrameFromLayout(textViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: textViewLayout, relativeViewFrame: relativeViewFrame!)
    }

    
    func updateView() {
        
        self.backgroundColor = textViewObject?.backgroundColor != nil ? Utility.hexStringToUIColor(hex: (textViewObject?.textColor)!) : UIColor.clear
        
        var fontSize:Float?
        
        if textViewLayout?.fontSize != nil {
            fontSize = textViewLayout?.fontSize
        }
        else if textViewObject?.fontSize != nil {
            fontSize = textViewObject?.fontSize
        }
        
        var fontFamily:String?

        if textViewObject?.fontFamily != nil {
            
            if textViewObject?.fontWeight != nil {
                
                var fontWeight = (textViewObject?.fontWeight)!
                
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
        
        self.textColor = Utility.hexStringToUIColor(hex: textViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
        
        if textViewObject?.textAlignment == "center" {
            self.textAlignment = .center
        }
        else if textViewObject?.textAlignment == "left" {
            self.textAlignment = .left
        }
        else if textViewObject?.textAlignment == "right" {
            self.textAlignment = .right
        }
        else {
            self.textAlignment = .natural
        }        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
