//
//  SFDropDown.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol dropDownProtocol: NSObjectProtocol {
    @objc optional func dropDownTapped() -> Void
}

class SFDropDown: UITextField, UITextFieldDelegate {
    
    var dropDownText:String?
    var dropDownObject:SFDropDownObject?
    var dropDownLayout:LayoutObject?
    var relativeViewFrame:CGRect?
    weak var dropDownDelegate: dropDownProtocol?
    
    func initialiseDropDownFrameFromLayout(dropDownLayout:LayoutObject) {
        self.delegate = self
        self.frame = Utility.initialiseViewLayout(viewLayout: dropDownLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func updateView() {
        
        self.backgroundColor = dropDownObject?.backgroundColor != nil ? Utility.hexStringToUIColor(hex: (dropDownObject?.backgroundColor)!) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        var fontSize:Float?
        
        if dropDownLayout?.fontSize != nil {
            fontSize = dropDownLayout?.fontSize
        }
        else if dropDownObject?.fontSize != nil {
            fontSize = dropDownObject?.fontSize
        }
        
        var fontFamily:String?
        
//        if dropDownObject?.fontFamily != nil {
//            
//            if dropDownObject?.fontWeight != nil {
//                
//                fontFamily = "\((dropDownObject?.fontFamily)!)-\((dropDownObject?.fontWeight)!)"
//                
//            }
//            else {
//                fontFamily = "\((dropDownObject?.fontFamily)!)"
//            }
//        }
        
        if dropDownObject?.fontFamily != nil {
            
            if dropDownObject?.fontWeight != nil {
                
                var fontWeight = (dropDownObject?.fontWeight)!
                
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
        
        self.textColor = Utility.hexStringToUIColor(hex: dropDownObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
        
        #if os(tvOS)
            self.borderStyle = .roundedRect
        #endif
        
        
        if dropDownObject?.textAlignment == "center" {
            self.textAlignment = .center
        }
        else if dropDownObject?.textAlignment == "left" {
            self.textAlignment = .left
        }
        else if dropDownObject?.textAlignment == "right" {
            self.textAlignment = .right
        }
        else {
            self.textAlignment = .natural
        }
        
        if dropDownObject?.text != nil {
            self.placeholder = dropDownObject?.text
        }
        
        self.isSecureTextEntry = (dropDownObject?.isProtected)!
        
        self.autocorrectionType = .no
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if self.dropDownDelegate != nil && (self.dropDownDelegate?.responds(to: #selector(self.dropDownDelegate?.dropDownTapped)))!
//        {
//            self.dropDownDelegate?.dropDownTapped!()
//        }
//        return false
//    }
    
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
