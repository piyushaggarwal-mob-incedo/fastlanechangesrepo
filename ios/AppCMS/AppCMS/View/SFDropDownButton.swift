//
//  SFDropDownButton.swift
//  AppCMS
//
//  Created by Gaurav Vig on 27/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFDropDownButtonDelegate:NSObjectProtocol {
    @objc func buttonClicked(button:SFDropDownButton) -> Void
}

class SFDropDownButton: UIButton {
    
    var buttonAction:String = ""
    weak var buttonDelegate:SFDropDownButtonDelegate?
    var buttonObject:SFDropDownButtonObject?
    var relativeViewFrame:CGRect?
    var buttonLayout:LayoutObject?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseDropDownButtonFrameFromLayout(dropDownButtonLayout:LayoutObject) {
        
        self.buttonLayout = dropDownButtonLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: dropDownButtonLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createButtonView() -> Void {
        
        if ((buttonObject?.backgroundColor) != nil) {
            
            self.backgroundColor = Utility.hexStringToUIColor(hex: (buttonObject?.backgroundColor)!)
        }
        else {
            
            self.backgroundColor = UIColor.clear
        }
        
        if buttonObject?.textColor != nil {
            
            self.titleLabel?.textColor = Utility.hexStringToUIColor(hex: (buttonObject?.textColor)!)
        }
        else {
            self.titleLabel?.textColor = UIColor.black
        }
        
        self.setTitle(buttonObject?.text, for: UIControlState.normal)
        self.setTitleColor(buttonObject?.textColor != nil ?Utility.hexStringToUIColor(hex:(buttonObject?.textColor)!):UIColor.white, for: UIControlState.normal)
        
        var fontSize:Float?
        
        if buttonLayout?.fontSize != nil {
            fontSize = buttonLayout?.fontSize
        }
        
        var fontFamily:String?
        
        if buttonObject?.fontFamily != nil {
            
            if buttonObject?.fontWeight != nil {
                
                fontFamily = "\((buttonObject?.fontFamily)!)-\((buttonObject?.fontWeight)!)"
                
            }
            else {
                fontFamily = "\((buttonObject?.fontFamily)!)"
            }
        }
        
        if fontFamily != nil && fontSize != nil {
            
            self.titleLabel?.font = UIFont(name: fontFamily!, size: CGFloat(fontSize!))
        }
        
        if buttonObject?.imageName != nil
        {
            let dropdownButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "icon-dropDown.png"))
            
            self.setImage(dropdownButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }

        
        self.contentHorizontalAlignment = .left
    }
    
    
    func buttonClicked(sender: SFDropDownButton!) -> Void {
        
        if buttonDelegate != nil && (buttonDelegate?.responds(to: #selector(SFDropDownButtonDelegate.buttonClicked(button:))))! {
            
            buttonDelegate?.buttonClicked(button: sender)
        }
    }
    
    func updateButtonTitle(buttonText:String) {
        
        self.setTitle(buttonText, for: .normal)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
