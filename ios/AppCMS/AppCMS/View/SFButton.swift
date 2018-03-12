//
//  SFButton.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

@objc protocol SFButtonDelegate:NSObjectProtocol {
    @objc func buttonClicked(button:SFButton) -> Void
}

class SFButton: UIButton {
    
    var buttonAction:String = ""
    weak var buttonDelegate:SFButtonDelegate?
    var buttonObject:SFButtonObject?
    var relativeViewFrame:CGRect?
    var buttonLayout:LayoutObject?
    
    #if os(tvOS)
    override var isSelected: Bool {
        didSet {
            //Ugly hack in order to fix automatic text change on focused state to normal state text.
            if self.isSelected {
                //            self.setTitle(buttonObject?.selectedStateText, for: UIControlState.focused)
                self.setTitle(buttonObject?.selectedStateText, for: UIControlState.normal)
            } else {
                //            self.setTitleColor(buttonObject?.textColor != nil ?Utility.hexStringToUIColor(hex:(buttonObject?.textColor)!):UIColor.white, for: UIControlState.focused)
                self.setTitle(buttonObject?.text, for: UIControlState.normal)

            }
        }
    }
    
    var buttonShowsAnImage: Bool = false
    #endif

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        #if os(iOS)
            self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)

        #else
            self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .primaryActionTriggered)
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseButtonFrameFromLayout(buttonLayout:LayoutObject) {
        self.buttonLayout = buttonLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: buttonLayout, relativeViewFrame: relativeViewFrame!)
    }

    func createButtonView() -> Void {
        
        if ((buttonObject?.backgroundColor) != nil) {
            
            self.backgroundColor = Utility.hexStringToUIColor(hex: (buttonObject?.backgroundColor)!)
        }
        else {
            
            self.backgroundColor = UIColor.clear
        }
        
        if ((buttonObject?.borderColor) != nil) {
            
            self.layer.borderColor = Utility.hexStringToUIColor(hex: (buttonObject?.borderColor)!).cgColor
        }
        
        if buttonObject?.textColor != nil {
            
            self.titleLabel?.textColor = Utility.hexStringToUIColor(hex: (buttonObject?.textColor)!)
        }
        else {
            self.titleLabel?.textColor = UIColor.black
        }
        
        if buttonObject?.borderWidth != nil {
            self.layer.borderWidth = CGFloat((buttonObject?.borderWidth)!)
        }
        
        if buttonObject?.cornerRadius != nil {
            
            self.layer.cornerRadius = CGFloat((buttonObject?.cornerRadius)!)
        }
        
        self.setTitle(buttonObject?.text, for: UIControlState.normal)
        self.setTitleColor(buttonObject?.textColor != nil ?Utility.hexStringToUIColor(hex:(buttonObject?.textColor)!):UIColor.white, for: UIControlState.normal)
        
        var fontSize:Float?
        
        if buttonLayout?.fontSize != nil {
            
            fontSize = buttonLayout?.fontSize
        }
        else if buttonObject?.textFontSize != nil {
            
            fontSize = buttonObject?.textFontSize
        }
        
        var fontFamily:String?
        
        if buttonObject?.fontFamily != nil {
            
            if buttonObject?.fontWeight != nil {
                
                var fontWeight = (buttonObject?.fontWeight)!
                
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
            
            self.titleLabel?.font = UIFont(name: fontFamily!, size: CGFloat(fontSize!))
        }
        
        if buttonObject?.selectedStateText != nil {
            self.setTitle(buttonObject?.selectedStateText, for: UIControlState.selected)
        }
        
        #if os(tvOS)
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
                self.alpha = 0.5
            }
        #endif
    }

        
    func buttonClicked(sender: SFButton!) -> Void {

        if buttonDelegate != nil && (buttonDelegate?.responds(to: #selector(SFButtonDelegate.buttonClicked(button:))))! {
            
            buttonDelegate?.buttonClicked(button: sender)
        }
    }
    
    #if os(tvOS)
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        if self.isFocused {
            updateViewForFocusedState()
        } else {
            updateViewForUnFocusedState()
        }
    }
    
    func updateViewForFocusedState() {
        
        DispatchQueue.main.async {
            //Check added to find buttons which have image added.
            if self.imageView?.image == nil && self.buttonShowsAnImage == false {
                if let backGroundColor = AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor {
                    self.backgroundColor = Utility.hexStringToUIColor(hex: backGroundColor)
                }
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.textColor {
                    self.titleLabel?.textColor = Utility.hexStringToUIColor(hex: textColor)
                }
            }
            
            if let borderColor = AppConfiguration.sharedAppConfiguration.primaryButton.borderSelectedColor {
                self.layer.borderColor = Utility.hexStringToUIColor(hex: borderColor).cgColor
            }
            if self.buttonObject?.borderWidth != nil {
                self.layer.borderWidth = CGFloat((self.buttonObject?.borderWidth)!)
            }
            self.alpha = 1.0
        }
    }
    
    
    func updateViewForUnFocusedState() {
    
        DispatchQueue.main.async {
            //Check added to find buttons which have image added.
            if self.imageView?.image == nil && self.buttonShowsAnImage == false  {
                if ((self.buttonObject?.backgroundColor) != nil) {
                    self.backgroundColor = Utility.hexStringToUIColor(hex: (self.buttonObject?.backgroundColor)!)
                }
                else {
                    self.backgroundColor = UIColor.clear
                }
                if ((self.buttonObject?.borderColor) != nil) {
                    
                    self.layer.borderColor = Utility.hexStringToUIColor(hex: (self.buttonObject?.borderColor)!).cgColor
                }
                
                if self.buttonObject?.borderWidth != nil {
                    
                    self.layer.borderWidth = CGFloat((self.buttonObject?.borderWidth)!)
                }
                if self.buttonObject?.textColor != nil {
                    self.titleLabel?.textColor = Utility.hexStringToUIColor(hex: (self.buttonObject?.textColor)!)
                }
                else {
                    self.titleLabel?.textColor = UIColor.black
                }
            }
            else {
                
                if ((self.buttonObject?.borderColor) != nil) {
                    
                    self.layer.borderColor = UIColor.clear.cgColor
                }
                
                if self.buttonObject?.borderWidth != nil {
                    
                    self.layer.borderWidth = 0
                }
            }
    
            
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
                self.alpha = 0.5
            }
        }
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
