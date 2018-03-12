//
//  SFSeparatorView.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 17/03/17.
//
//

import UIKit

class SFSeparatorView: UIView {
    
    var separtorViewObject:SFSeparatorViewObject?
    var relativeViewFrame:CGRect?
    
    func initialiseSeparatorViewFrameFromLayout(separatorViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: separatorViewLayout, relativeViewFrame: relativeViewFrame!)
        self.backgroundColor = Utility.hexStringToUIColor(hex: separtorViewObject?.backgroundColor ?? "000000")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
