//
//  SFMorePopUpTableCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFMorePopUpTableCellDelegate:NSObjectProtocol {
    @objc optional func buttonClicked(button:UIButton, buttonAction:MorePopUpOptions, externalWebLink:String?) -> Void
}

class SFMorePopUpTableCell: UITableViewCell {

    var button:UIButton!
    var buttonAction:MorePopUpOptions!
    var cellFrame:CGRect!
    var externalWebLinkUrl:String?
    weak var cellDelegate:SFMorePopUpTableCellDelegate?
    
    func createCellView() {
    
        button = UIButton(type: .custom)
        button.frame = cellFrame
        button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Lato-Bold", size: 16)
        button.autoresizingMask = [.flexibleWidth]
        self.addSubview(button)
    }
    
    func buttonTapped() {
        
        if self.cellDelegate != nil {
            
            if (cellDelegate?.responds(to: #selector(SFMorePopUpTableCellDelegate.buttonClicked(button:buttonAction:externalWebLink:))))! {
                
                cellDelegate?.buttonClicked!(button: button, buttonAction: buttonAction, externalWebLink: externalWebLinkUrl)
            }
        }
    }

    
    func createButtonText(buttonText:String) {
        
        button.setTitle(buttonText, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
