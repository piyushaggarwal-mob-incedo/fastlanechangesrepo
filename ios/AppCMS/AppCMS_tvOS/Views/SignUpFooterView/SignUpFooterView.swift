//
//  SignUpFooterView.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 17/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit


@objc protocol signUpFooterViewDelegate: NSObjectProtocol {
    @objc optional func loadAncillaryPage(_ type : String) -> Void
}


class SignUpFooterView: UIView {

    //MARK: - Button object refrencing UIButton in XIB.
   @IBOutlet  var tosbutton : UIButton!
   @IBOutlet  var privacyPolicybutton : UIButton!
   @IBOutlet  var underLineViewForTOS : UIView!
   @IBOutlet  var underLineViewForPP : UIView!
    
   weak var delegate: signUpFooterViewDelegate?


   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    self.underLineViewForPP.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
    self.underLineViewForTOS.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
    self.tosbutton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"), for: .normal)
    self.privacyPolicybutton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"), for: .normal)
  }


    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SignUpFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        self.underLineViewForTOS.isHidden = true
        self.underLineViewForPP.isHidden = true
        
        if context.nextFocusedView == tosbutton  {
            
            self.underLineViewForTOS.isHidden = false
            
        } else  if context.nextFocusedView == privacyPolicybutton {
           
            self.underLineViewForPP.isHidden = false
        }
    }
    
    //MARK: - Action handler
    @IBAction func loadAncillaryDataForSelectedPage(_ sender: Any) {
        
        
        var pageName : String?
        
        if (sender as! UIButton).tag == 2 {
             pageName = "Privacy Policy"
        }
        else{
            pageName = "Terms"
        }
        
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.loadAncillaryPage(_:))))!
        {
            self.delegate?.loadAncillaryPage!(pageName!)
        }
        
    }
    
    
}
