//
//  SFTextField.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTextField: UITextField {
    
    var textFieldText:String?
    var textFieldObject:SFTextFieldObject?
    var textFieldLayout:LayoutObject?
    var relativeViewFrame:CGRect?
    
    func initialiseTextViewFrameFromLayout(textFieldLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: textFieldLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    
    func updateView() {
        
        self.backgroundColor = textFieldObject?.backgroundColor != nil ? Utility.hexStringToUIColor(hex: (textFieldObject?.backgroundColor)!) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        var fontSize:Float?
        
        if textFieldLayout?.fontSize != nil {
            fontSize = textFieldLayout?.fontSize
        }
        else if textFieldObject?.fontSize != nil {
            fontSize = textFieldObject?.fontSize
        }
        
        var fontFamily:String?
                
        if textFieldObject?.fontFamily != nil {
            
            if textFieldObject?.fontWeight != nil {
                
                var fontWeight = (textFieldObject?.fontWeight)!
                
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
        
        self.textColor = Utility.hexStringToUIColor(hex: textFieldObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
        
        #if os(tvOS)
            self.borderStyle = .roundedRect
        #endif

        
        if textFieldObject?.textAlignment == "center" {
            self.textAlignment = .center
        }
        else if textFieldObject?.textAlignment == "left" {
            self.textAlignment = .left
        }
        else if textFieldObject?.textAlignment == "right" {
            self.textAlignment = .right
        }
        else {
            self.textAlignment = .natural
        }
        
        if textFieldObject?.text != nil {
            self.placeholder = textFieldObject?.text
        }
        
        self.isSecureTextEntry = (textFieldObject?.isProtected)!
        
        self.autocorrectionType = .no
        if textFieldObject?.key == "mobile text field"
        {
            self.keyboardType = .numberPad
        }
        else if textFieldObject?.key == "emailTextField"
        {
            self.keyboardType = .emailAddress
        }
        else
        {
            self.keyboardType = .default
        }
    }
    
    #if os(iOS)
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(bounds, padding)
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
