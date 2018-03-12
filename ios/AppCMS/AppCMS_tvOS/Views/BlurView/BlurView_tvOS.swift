//
//  BlurView_tvOs.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class BlurView_tvOS: UIView {

    override var canBecomeFocused: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor(red: 23/255, green: 40/255, blue: 50/255, alpha: 0.6)
    }
    
    func addBlurEffect () {
        if self.isBlurred == false {
            self.blur(blurRadius: 2.0)
        }
    }
}
