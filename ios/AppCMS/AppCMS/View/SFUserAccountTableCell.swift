//
//  SFUserAccountTableCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 01/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFUserAccountTableCell: UITableViewCell {

    var userAccountView:UserAccount?
    var relativeViewFrame:CGRect?
    var userAccountObject:UserAccountModuleObject?
    var userAccountViewObject:UserAccountComponentObject?
    var userDetails:SFUserDetails?
    var userAccountLayout:LayoutObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    
    init(userAccountObject:UserAccountModuleObject, userAccountViewObject:UserAccountComponentObject, userAccountLayout:LayoutObject, relativeViewFrame:CGRect) {
        
        self.userAccountObject = userAccountObject
        self.userAccountViewObject = userAccountViewObject
        self.relativeViewFrame = relativeViewFrame
        self.userAccountLayout = userAccountLayout
        self.relativeViewFrame = relativeViewFrame
        
        super.init(style: .default, reuseIdentifier: "userAccountCell")
        
        self.createUserAccountView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: method to create user account view
    func createUserAccountView() {
        
        let userAccountLayout = Utility.fetchUserAccountViewLayoutDetails(userAccountViewObject: userAccountViewObject!)
        userAccountView = UserAccount.init(frame: relativeViewFrame!, userAccountObject: userAccountObject!, userAccountViewObject: userAccountViewObject!, viewTag: 0)
        userAccountView?.userAccountViewLayout = userAccountLayout
        userAccountView?.userAccountViewObject = userAccountViewObject
        userAccountView?.relativeViewFrame = relativeViewFrame!

        self.contentView.addSubview(userAccountView!)
    }
    
    override func layoutSubviews() {
        
        self.changeFrameWidth(width: UIScreen.main.bounds.width)
        self.contentView.changeFrameWidth(width: UIScreen.main.bounds.width)

        relativeViewFrame?.size.width = UIScreen.main.bounds.width
        userAccountView?.relativeViewFrame = relativeViewFrame!
        userAccountView?.changeFrameWidth(width: (relativeViewFrame?.size.width)!)
        userAccountView?.updateView()
    }
}
