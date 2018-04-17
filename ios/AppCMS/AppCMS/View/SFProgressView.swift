//
//  SFProgressView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 27/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProgressView: UIProgressView {

    var progressViewObject:SFProgressViewObject?
    var relativeViewFrame:CGRect?
    
    func initialiseProgressViewFrameFromLayout(progressViewLayout:LayoutObject) {
        
        let progressViewFrame = Utility.initialiseViewLayout(viewLayout: progressViewLayout, relativeViewFrame: relativeViewFrame!)
        self.frame = progressViewFrame
    }
    
    func updateProgressView() {
        
        self.progressTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
        self.trackTintColor = Utility.hexStringToUIColor(hex: (progressViewObject?.unprogressColor)!)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let newSize:CGSize = CGSize(width: size.width, height: size.height)
        
        return newSize
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
