//
//  SFToggle.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 01/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFToggleDelegate: NSObjectProtocol {
    @objc func toggleValueDidChange(sender: SFToggle)
}

class SFToggle: UISwitch {

    weak var toggleDelegate:SFToggleDelegate?
    var toggleObject:SFToggleObject?
    var relativeViewFrame:CGRect?
    var toggleLayout:LayoutObject?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(toggleValueChanged(sender:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialiseToggleFrameFromLayout(toggleLayout:LayoutObject) {
        self.toggleLayout = toggleLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: toggleLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func createToggleView() -> Void {
        self.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
        self.onTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
    }
    
    
    func toggleValueChanged(sender: SFToggle!) -> Void {
        if self.toggleDelegate != nil && (self.toggleDelegate?.responds(to: #selector(SFButtonDelegate.buttonClicked(button:))))!
        {
            self.toggleDelegate?.toggleValueDidChange(sender: sender)
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
